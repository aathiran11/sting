import express from "express";
import { q } from "../db.js";
import { requireAuth } from "../middleware/auth.js";

const router = express.Router();

const publicUser = (u) => ({
  id: u.id,
  username: u.username,
  name: u.name,
  bio: u.bio,
  interest: u.interest,
  avatarUrl: u.avatar_url,
  isPrivate: u.is_private,
  currentStreak: u.current_streak,
  longestStreak: u.longest_streak,
  streakTier: u.streak_tier || "None",
  stingScore: u.sting_score || 100,
  freezePasses: u.freeze_passes ?? 1,
  createdAt: u.created_at,
});

// GET /api/users/me
router.get("/me", requireAuth, async (req, res) => {
  const result = await q("SELECT * FROM users WHERE id = $1", [req.userId]);
  if (!result.rows.length) return res.status(404).json({ error: "Not found" });
  res.json(publicUser(result.rows[0]));
});

// POST /api/users/me/freeze (Use a Freeze Pass to protect streak)
router.post("/me/freeze", requireAuth, async (req, res) => {
  const userRes = await q("SELECT freeze_passes, last_freeze_date FROM users WHERE id = $1", [req.userId]);
  const user = userRes.rows[0];

  if (!user || user.freeze_passes <= 0) {
    return res.status(400).json({ error: "No Freeze Passes available. You receive 1 every 90 days." });
  }

  const updated = await q(
    `UPDATE users 
     SET freeze_passes = freeze_passes - 1, last_freeze_date = CURRENT_DATE 
     WHERE id = $1 RETURNING *`,
    [req.userId]
  );

  res.json({
    message: "Sting Freeze activated! Your streak is safely preserved for today.",
    user: publicUser(updated.rows[0]),
  });
});

// GET /api/users/me/recap (Weekly Growth Recap)
router.get("/me/recap", requireAuth, async (req, res) => {
  const userRes = await q("SELECT * FROM users WHERE id = $1", [req.userId]);
  const user = userRes.rows[0];

  const recentPosts = await q(
    `SELECT COUNT(*)::int AS count 
     FROM posts 
     WHERE user_id = $1 AND created_at >= now() - interval '7 days'`,
    [req.userId]
  );

  const verificationRes = await q(
    `SELECT COUNT(*) FILTER (WHERE reaction = 'verified')::int AS v_count,
            COUNT(*) FILTER (WHERE reaction = 'inspiring')::int AS i_count
     FROM post_verifications pv
     JOIN posts p ON p.id = pv.post_id
     WHERE p.user_id = $1 AND pv.created_at >= now() - interval '7 days'`,
    [req.userId]
  );

  res.json({
    username: user.username,
    name: user.name,
    challengesCompletedThisWeek: recentPosts.rows[0]?.count || 0,
    currentStreak: user.current_streak,
    streakTier: user.streak_tier || "None",
    stingScore: user.sting_score || 100,
    verifiedReceived: verificationRes.rows[0]?.v_count || 0,
    inspiringReceived: verificationRes.rows[0]?.i_count || 0,
    weeklyMood: "High Discipline",
  });
});

// PUT /api/users/me  { username?, name?, bio?, interest?, isPrivate? }
router.put("/me", requireAuth, async (req, res) => {
  const { username, name, bio, interest, isPrivate } = req.body;

  if (username) {
    const taken = await q("SELECT id FROM users WHERE username = $1 AND id <> $2", [username, req.userId]);
    if (taken.rows.length) return res.status(409).json({ error: "Username already taken." });
  }

  const result = await q(
    `UPDATE users SET
       username = COALESCE($1, username),
       name = COALESCE($2, name),
       bio = COALESCE($3, bio),
       interest = COALESCE($4, interest),
       is_private = COALESCE($5, is_private)
     WHERE id = $6 RETURNING *`,
    [username, name, bio, interest, isPrivate, req.userId]
  );
  res.json(publicUser(result.rows[0]));
});

// GET /api/users/:username
router.get("/:username", async (req, res) => {
  const result = await q("SELECT * FROM users WHERE username = $1", [req.params.username]);
  if (!result.rows.length) return res.status(404).json({ error: "User not found" });
  res.json(publicUser(result.rows[0]));
});

export default router;
