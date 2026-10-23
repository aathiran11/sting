import "express-async-errors";
import express from "express";
import cors from "cors";
import path from "path";
import fs from "fs";
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
import { pool, q } from "./db.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "..", "uploads")));

app.get("/", (req, res) => res.json({ name: "Sting API", status: "online", version: "1.0.0" }));

const healthHandler = async (req, res) => {
  try {
    await q("SELECT 1");
    res.json({ ok: true, database: "connected" });
  } catch (err) {
    res.json({ ok: true, database: "warning", message: err.message });
  }
};
app.get("/health", healthHandler);
app.get("/api/health", healthHandler);

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/follow", followRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/posts", postRoutes);
app.use("/api/feed", feedRoutes);
app.use("/api/leaderboard", leaderboardRoutes);
app.use("/api/challenges", challengeRoutes);

// Global Error Handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error("API error:", err);
  res.status(err.status || 500).json({ error: err.message || "Something went wrong." });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, "0.0.0.0", async () => {
  console.log(`Sting API running on port ${PORT}`);
  try {
    await pool.query("CREATE SCHEMA IF NOT EXISTS sting;");
    const sql = fs.readFileSync(path.join(__dirname, "..", "sql", "schema.sql"), "utf8");
    await pool.query(sql);
    console.log("Database schema synced successfully.");
  } catch (err) {
    console.warn("Database sync notice:", err.message);
  }
});

