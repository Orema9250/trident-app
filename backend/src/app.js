const express = require("express");
const cors = require("cors");
const pool = require("./database");
const taskRoutes = require("./routes/tasks");

const app = express();

const allowedOrigins = [
  "http://localhost",
  "http://localhost:5173",
  "https://orema-devops.xyz"
];

if (process.env.FRONTEND_URL) {
  allowedOrigins.push(process.env.FRONTEND_URL);
}

app.use(
  cors({
    origin: allowedOrigins,
  })
);

app.use(express.json());


/*
Basic application health check.

This endpoint should NOT depend on PostgreSQL.

Your ALB should use this endpoint.
*/
app.get("/api/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    service: "cloudtask-backend",
  });
});


/*
Database health check.

Useful for troubleshooting RDS connectivity separately.
*/
app.get("/api/db-health", async (req, res) => {
  try {
    await pool.query("SELECT 1");

    res.status(200).json({
      status: "healthy",
      database: "connected",
    });
  } catch (error) {
    console.error("Database health check failed:", error);

    res.status(503).json({
      status: "unhealthy",
      database: "disconnected",
    });
  }
});


app.use("/api/tasks", taskRoutes);


app.use((req, res) => {
  res.status(404).json({
    error: "Route not found",
  });
});


module.exports = app;
