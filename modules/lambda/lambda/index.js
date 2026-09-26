import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

import {
  DynamoDBDocumentClient,
  PutCommand,
  ScanCommand,
  GetCommand,
  UpdateCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

import crypto from "crypto";


/*
DynamoDB configuration
*/
const dynamoConfig = {
  region: process.env.AWS_REGION || "us-east-1",
};

// Useful for local DynamoDB testing
if (process.env.DYNAMODB_ENDPOINT) {
  dynamoConfig.endpoint = process.env.DYNAMODB_ENDPOINT;
}

const client = new DynamoDBClient(dynamoConfig);

const dynamodb = DynamoDBDocumentClient.from(client);

const TABLE_NAME =
  process.env.ACTIVITY_TABLE || "cloudtask-activities";


/*
Standard API response
*/
function response(statusCode, body) {
  return {
    statusCode,

    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers":
        "Content-Type,Authorization",
      "Access-Control-Allow-Methods":
        "GET,POST,PUT,DELETE,OPTIONS",
    },

    body: JSON.stringify(body),
  };
}


/*
Lambda handler
*/
export const handler = async (event) => {
  console.log("Received event:", JSON.stringify(event));

  /*
  API Gateway HTTP API already tells us which
  route matched.

  Examples:
  GET /health
  GET /activities
  POST /activities
  GET /activities/{id}
  PUT /activities/{id}
  DELETE /activities/{id}
  */
  const routeKey = event.routeKey;

  console.log("Route:", routeKey);


  /*
  OPTIONS / CORS
  */
  if (
    event.requestContext?.http?.method === "OPTIONS"
  ) {
    return response(200, {
      message: "OK",
    });
  }


  /*
  GET /health

  Keep this route public in API Gateway.
  */
  if (routeKey === "GET /health") {
    return response(200, {
      status: "healthy",
      service: "activity-lambda",
    });
  }


  /*
  POST /activities

  Create a new activity.
  */
  if (routeKey === "POST /activities") {
    try {
      const body =
        typeof event.body === "string"
          ? JSON.parse(event.body)
          : event.body;

      if (!body?.eventType || !body?.message) {
        return response(400, {
          error: "eventType and message are required",
        });
      }

      const activity = {
        id: crypto.randomUUID(),
        eventType: body.eventType,
        message: body.message,
        createdAt: new Date().toISOString(),
      };

      await dynamodb.send(
        new PutCommand({
          TableName: TABLE_NAME,
          Item: activity,
        })
      );

      return response(201, activity);
    } catch (error) {
      console.error(
        "Create activity error:",
        error
      );

      return response(500, {
        error: "Failed to create activity",
      });
    }
  }


  /*
  GET /activities

  Return all activities.
  */
  if (routeKey === "GET /activities") {
    try {
      const result = await dynamodb.send(
        new ScanCommand({
          TableName: TABLE_NAME,
        })
      );

      const activities = result.Items || [];

      activities.sort(
        (a, b) =>
          new Date(b.createdAt) -
          new Date(a.createdAt)
      );

      return response(200, activities);
    } catch (error) {
      console.error(
        "Get activities error:",
        error
      );

      return response(500, {
        error: "Failed to retrieve activities",
      });
    }
  }


  /*
  GET /activities/{id}

  Return one activity.
  */
  if (routeKey === "GET /activities/{id}") {
    try {
      const id =
        event.pathParameters?.id;

      if (!id) {
        return response(400, {
          error: "Activity ID is required",
        });
      }

      const result = await dynamodb.send(
        new GetCommand({
          TableName: TABLE_NAME,

          Key: {
            id,
          },
        })
      );

      if (!result.Item) {
        return response(404, {
          error: "Activity not found",
        });
      }

      return response(200, result.Item);
    } catch (error) {
      console.error(
        "Get activity error:",
        error
      );

      return response(500, {
        error: "Failed to retrieve activity",
      });
    }
  }


  /*
  PUT /activities/{id}

  Update an existing activity.
  */
  if (routeKey === "PUT /activities/{id}") {
    try {
      const id =
        event.pathParameters?.id;

      if (!id) {
        return response(400, {
          error: "Activity ID is required",
        });
      }

      const body =
        typeof event.body === "string"
          ? JSON.parse(event.body)
          : event.body;

      if (!body?.eventType || !body?.message) {
        return response(400, {
          error: "eventType and message are required",
        });
      }

      const result = await dynamodb.send(
        new UpdateCommand({
          TableName: TABLE_NAME,

          Key: {
            id,
          },

          UpdateExpression:
            "SET eventType = :eventType, #message = :message",

          ExpressionAttributeNames: {
            "#message": "message",
          },

          ExpressionAttributeValues: {
            ":eventType": body.eventType,
            ":message": body.message,
          },

          ReturnValues: "ALL_NEW",
        })
      );

      return response(
        200,
        result.Attributes
      );
    } catch (error) {
      console.error(
        "Update activity error:",
        error
      );

      return response(500, {
        error: "Failed to update activity",
      });
    }
  }


  /*
  DELETE /activities/{id}

  Delete an activity.
  */
  if (
    routeKey ===
    "DELETE /activities/{id}"
  ) {
    try {
      const id =
        event.pathParameters?.id;

      if (!id) {
        return response(400, {
          error: "Activity ID is required",
        });
      }

      await dynamodb.send(
        new DeleteCommand({
          TableName: TABLE_NAME,

          Key: {
            id,
          },
        })
      );

      return response(200, {
        message: "Activity deleted",
        id,
      });
    } catch (error) {
      console.error(
        "Delete activity error:",
        error
      );

      return response(500, {
        error: "Failed to delete activity",
      });
    }
  }


  /*
  Fallback
  */
  return response(404, {
    error: "Route not found",
  });
};