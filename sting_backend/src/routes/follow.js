import express from "express";
import { q } from "../db.js";
import { requireAuth } from "../middleware/auth.js";

const router = express.Router();

async function userIdForUsername(username) {
  const r = await q("SELECT id FROM users WHERE username = $1", [username]);
  return r.rows[0]?.id || null;
}

// POST /api/follow/:username
router.post("/:username", requireAuth, async (req, res) => {
  const targetId = await userIdForUsername(req.params.username);
  if (!targetId) return res.status(404).json({ error: "User not found" });
  if (targetId === req.userId) return res.status(400).json({ error: "Can't follow yourself" });

  await q(
    "INSERT INTO follows (follower_id, following_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
    [req.userId, targetId]
  );
  res.json({ following: true });
});

// DELETE /api/follow/:username
router.delete("/:username", requireAuth, async (req, res) => {
  const targetId = await userIdForUsername(req.params.username);
  if (!targetId) return res.status(404).json({ error: "User not found" });

  await q("DELETE FROM follows WHERE follower_id = $1 AND following_id = $2", [req.userId, targetId]);
  res.json({ following: false });
});

// GET /api/follow/:username/following
router.get("/:username/following", async (req, res) => {
  const userId = await userIdForUsername(req.params.username);
  if (!userId) return res.status(404).json({ error: "User not found" });

  const result = await q(
    `SELECT u.username, u.name, u.current_streak
     FROM follows f JOIN users u ON u.id = f.following_id
     WHERE f.follower_id = $1 ORDER BY f.created_at DESC`,
    [userId]
  );
  res.json(result.rows);
});

// GET /api/follow/:username/followers
router.get("/:username/followers", async (req, res) => {
  const userId = await userIdForUsername(req.params.username);
  if (!userId) return res.status(404).json({ error: "User not found" });

  const result = await q(
    `SELECT u.username, u.name, u.current_streak
     FROM follows f JOIN users u ON u.id = f.follower_id
     WHERE f.following_id = $1 ORDER BY f.created_at DESC`,
    [userId]
  );
  res.json(result.rows);
});

// GET /api/follow/suggested  (auth) — same-interest users you don't already follow
router.get("/suggested/for-me", requireAuth, async (req, res) => {
  const me = await q("SELECT interest FROM users WHERE id = $1", [req.userId]);
  const interest = me.rows[0]?.interest || "";

  const result = await q(
    `SELECT username, name, bio, interest, current_streak
     FROM users
     WHERE id <> $1
       AND ($2 = '' OR interest = $2)
       AND id NOT IN (SELECT following_id FROM follows WHERE follower_id = $1)
     ORDER BY current_streak DESC
     LIMIT 20`,
    [req.userId, interest]
  );
  res.json(result.rows);
});

export default router;
