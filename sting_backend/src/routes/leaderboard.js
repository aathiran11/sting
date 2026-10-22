import express from "express";
import { q } from "../db.js";
import { requireAuth } from "../middleware/auth.js";

const router = express.Router();

// GET /api/leaderboard/streaks — Global Top Streaks
router.get("/streaks", async (req, res) => {
  try {
    const result = await q(
      `SELECT id, username, name,
              COALESCE(current_streak, 0) AS current_streak,
              COALESCE(streak_tier, 'None') AS streak_tier,
              COALESCE(sting_score, 100) AS sting_score,
              bio
       FROM users
       ORDER BY current_streak DESC, sting_score DESC
       LIMIT 50`
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Leaderboard error:", err.message);
    res.json([]);
  }
});

// GET /api/leaderboard/scores — Top Authentic Reputation (Sting Score)
router.get("/scores", async (req, res) => {
  try {
    const result = await q(
      `SELECT id, username, name,
              COALESCE(current_streak, 0) AS current_streak,
              COALESCE(streak_tier, 'None') AS streak_tier,
              COALESCE(sting_score, 100) AS sting_score,
              bio
       FROM users
       ORDER BY sting_score DESC, current_streak DESC
       LIMIT 50`
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Leaderboard error:", err.message);
    res.json([]);
  }
});

// GET /api/leaderboard/friends — Leaderboard among people you follow + yourself
router.get("/friends", requireAuth, async (req, res) => {
  try {
    const result = await q(
      `SELECT id, username, name,
              COALESCE(current_streak, 0) AS current_streak,
              COALESCE(streak_tier, 'None') AS streak_tier,
              COALESCE(sting_score, 100) AS sting_score,
              bio
       FROM users
       WHERE id = $1 OR id IN (SELECT following_id FROM follows WHERE follower_id = $1)
       ORDER BY current_streak DESC, sting_score DESC
       LIMIT 50`,
      [req.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Leaderboard error:", err.message);
    res.json([]);
  }
});

export default router;
