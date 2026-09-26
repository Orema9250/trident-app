import { useEffect, useState } from "react";
import "./index.css";


const BACKEND_URL =
  import.meta.env.VITE_BACKEND_URL;

const SERVERLESS_URL =
  import.meta.env.VITE_SERVERLESS_URL;


function App() {
  const [tasks, setTasks] = useState([]);
  const [activities, setActivities] = useState([]);

  const [title, setTitle] = useState("");
  const [description, setDescription] =
    useState("");

  const [backendStatus, setBackendStatus] =
    useState("checking");

  const [lambdaStatus, setLambdaStatus] =
    useState("checking");


  async function checkServices() {
    try {
      const response = await fetch(
        `${BACKEND_URL}/api/health`
      );

      setBackendStatus(
        response.ok ? "healthy" : "unhealthy"
      );
    } catch {
      setBackendStatus("unhealthy");
    }


    try {
      const response = await fetch(
        `${SERVERLESS_URL}/health`
      );

      setLambdaStatus(
        response.ok ? "healthy" : "unhealthy"
      );
    } catch {
      setLambdaStatus("unhealthy");
    }
  }


  async function loadTasks() {
    try {
      const response = await fetch(
        `${BACKEND_URL}/api/tasks`
      );

      if (!response.ok) {
        throw new Error("Failed to load tasks");
      }

      const data = await response.json();

      setTasks(data);
    } catch (error) {
      console.error(error);
    }
  }


  async function loadActivities() {
    try {
      const response = await fetch(
        `${SERVERLESS_URL}/activities`
      );

      if (!response.ok) {
        throw new Error(
          "Failed to load activities"
        );
      }

      const data = await response.json();

      setActivities(data);
    } catch (error) {
      console.error(error);
    }
  }


  async function createActivity(
    eventType,
    message
  ) {
    try {
      await fetch(
        `${SERVERLESS_URL}/activities`,
        {
          method: "POST",

          headers: {
            "Content-Type": "application/json",
          },

          body: JSON.stringify({
            eventType,
            message,
          }),
        }
      );

      await loadActivities();
    } catch (error) {
      console.error(
        "Failed to record activity:",
        error
      );
    }
  }


  async function createTask(event) {
    event.preventDefault();

    if (!title.trim()) {
      return;
    }

    try {
      const response = await fetch(
        `${BACKEND_URL}/api/tasks`,
        {
          method: "POST",

          headers: {
            "Content-Type": "application/json",
          },

          body: JSON.stringify({
            title,
            description,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Failed to create task");
      }

      const task = await response.json();

      setTitle("");
      setDescription("");

      await loadTasks();

      await createActivity(
        "TASK_CREATED",
        `Created task: ${task.title}`
      );
    } catch (error) {
      console.error(error);
    }
  }


  async function updateTask(id, status, title) {
    try {
      const response = await fetch(
        `${BACKEND_URL}/api/tasks/${id}`,
        {
          method: "PATCH",

          headers: {
            "Content-Type": "application/json",
          },

          body: JSON.stringify({
            status,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Failed to update task");
      }

      await loadTasks();

      await createActivity(
        "TASK_UPDATED",
        `${title} changed to ${status}`
      );
    } catch (error) {
      console.error(error);
    }
  }


  async function deleteTask(id, title) {
    try {
      const response = await fetch(
        `${BACKEND_URL}/api/tasks/${id}`,
        {
          method: "DELETE",
        }
      );

      if (!response.ok) {
        throw new Error("Failed to delete task");
      }

      await loadTasks();

      await createActivity(
        "TASK_DELETED",
        `Deleted task: ${title}`
      );
    } catch (error) {
      console.error(error);
    }
  }


  useEffect(() => {
    checkServices();
    loadTasks();
    loadActivities();
  }, []);


  return (
    <div className="app">
      <header>
        <div>
          <h1>CloudTask</h1>

          <p>
            ECS Fargate + Lambda Serverless
            Architecture
          </p>
        </div>

        <div className="services">
          <span>
            Fargate:
            <strong>
              {" "}
              {backendStatus}
            </strong>
          </span>

          <span>
            Lambda:
            <strong>
              {" "}
              {lambdaStatus}
            </strong>
          </span>
        </div>
      </header>


      <main>
        <section className="card">
          <h2>Create Task</h2>

          <form onSubmit={createTask}>
            <input
              type="text"
              placeholder="Task title"
              value={title}
              onChange={(event) =>
                setTitle(event.target.value)
              }
            />

            <textarea
              placeholder="Description"
              value={description}
              onChange={(event) =>
                setDescription(event.target.value)
              }
            />

            <button type="submit">
              Create Task
            </button>
          </form>
        </section>


        <section className="card">
          <h2>Tasks</h2>

          {tasks.length === 0 && (
            <p>No tasks yet.</p>
          )}

          <div className="task-list">
            {tasks.map((task) => (
              <article
                className="task"
                key={task.id}
              >
                <div>
                  <h3>{task.title}</h3>

                  <p>
                    {task.description ||
                      "No description"}
                  </p>

                  <span className="status">
                    {task.status}
                  </span>
                </div>

                <div className="actions">
                  <button
                    onClick={() =>
                      updateTask(
                        task.id,
                        "in-progress",
                        task.title
                      )
                    }
                  >
                    Start
                  </button>

                  <button
                    onClick={() =>
                      updateTask(
                        task.id,
                        "completed",
                        task.title
                      )
                    }
                  >
                    Complete
                  </button>

                  <button
                    onClick={() =>
                      deleteTask(
                        task.id,
                        task.title
                      )
                    }
                  >
                    Delete
                  </button>
                </div>
              </article>
            ))}
          </div>
        </section>


        <section className="card">
          <h2>Serverless Activity</h2>

          {activities.length === 0 && (
            <p>No activity recorded.</p>
          )}

          <div className="activity-list">
            {activities.map((activity) => (
              <article
                className="activity"
                key={activity.id}
              >
                <strong>
                  {activity.eventType}
                </strong>

                <p>{activity.message}</p>

                <small>
                  {new Date(
                    activity.createdAt
                  ).toLocaleString()}
                </small>
              </article>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}


export default App;
