import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import dotenv from "dotenv";
dotenv.config();

import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/users.js";
import followRoutes from "./routes/follow.js";
import taskRoutes from "./routes/tasks.js";
import postRoutes from "./routes/posts.js";
import feedRoutes from "./routes/feed.js";
import leaderboardRoutes from "./routes/leaderboard.js";
import challengeRoutes from "./routes/challenges.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "..", "uploads")));

app.get("/api/health", (req, res) => res.json({ ok: true }));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/follow", followRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/posts", postRoutes);
app.use("/api/feed", feedRoutes);
app.use("/api/leaderboard", leaderboardRoutes);
app.use("/api/challenges", challengeRoutes);

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || "Something went wrong." });
});

import fs from "fs";
import { pool } from "./db.js";

const PORT = process.env.PORT || 4000;
app.listen(PORT, async () => {
  console.log(`Sting API running on http://localhost:${PORT}`);
  try {
    const sql = fs.readFileSync(path.join(__dirname, "..", "sql", "schema.sql"), "utf8");
    await pool.query(sql);
    console.log("Database schema synced successfully.");
  } catch (err) {
    console.warn("Database sync notice (check Postgres is running):", err.message);
  }
});
