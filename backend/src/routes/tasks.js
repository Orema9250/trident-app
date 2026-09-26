const express = require("express");
const pool = require("../database");

const router = express.Router();


/*
GET /api/tasks
*/
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM tasks ORDER BY created_at DESC"
    );

    res.status(200).json(result.rows);
  } catch (error) {
    console.error("GET tasks error:", error);

    res.status(500).json({
      error: "Failed to retrieve tasks",
    });
  }
});


/*
POST /api/tasks
*/
router.post("/", async (req, res) => {
  const { title, description } = req.body;

  if (!title || !title.trim()) {
    return res.status(400).json({
      error: "Title is required",
    });
  }

  try {
    const result = await pool.query(
      `
      INSERT INTO tasks (title, description)
      VALUES ($1, $2)
      RETURNING *
      `,
      [title.trim(), description || null]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error("POST task error:", error);

    res.status(500).json({
      error: "Failed to create task",
    });
  }
});


/*
PATCH /api/tasks/:id
*/
router.patch("/:id", async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  const allowedStatuses = [
    "pending",
    "in-progress",
    "completed",
  ];

  if (!allowedStatuses.includes(status)) {
    return res.status(400).json({
      error: "Invalid status",
    });
  }

  try {
    const result = await pool.query(
      `
      UPDATE tasks
      SET status = $1
      WHERE id = $2
      RETURNING *
      `,
      [status, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: "Task not found",
      });
    }

    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error("PATCH task error:", error);

    res.status(500).json({
      error: "Failed to update task",
    });
  }
});


/*
DELETE /api/tasks/:id
*/
router.delete("/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `
      DELETE FROM tasks
      WHERE id = $1
      RETURNING id
      `,
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: "Task not found",
      });
    }

    res.status(200).json({
      message: "Task deleted",
      id: result.rows[0].id,
    });
  } catch (error) {
    console.error("DELETE task error:", error);

    res.status(500).json({
      error: "Failed to delete task",
    });
  }
});


module.exports = router;
