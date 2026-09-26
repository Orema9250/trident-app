import "dotenv/config";

import express from "express";
import cors from "cors";

import { handler } from "./index.js";


const app = express();

const PORT = process.env.PORT || 4000;


app.use(cors());

app.use(express.json());


async function invokeLambda(req, res) {
  const event = {
    rawPath: req.path,

    requestContext: {
      http: {
        method: req.method,
      },
    },

    body:
      req.body && Object.keys(req.body).length > 0
        ? JSON.stringify(req.body)
        : null,
  };


  try {
    const result = await handler(event);

    res
      .status(result.statusCode)
      .set(result.headers || {})
      .send(result.body);
  } catch (error) {
    console.error("Local Lambda invocation failed:", error);

    res.status(500).json({
      error: "Lambda invocation failed",
    });
  }
}


app.get("/health", invokeLambda);

app.get("/activities", invokeLambda);

app.post("/activities", invokeLambda);


app.listen(PORT, "0.0.0.0", () => {
  console.log(
    `Local Lambda API running on port ${PORT}`
  );
});
