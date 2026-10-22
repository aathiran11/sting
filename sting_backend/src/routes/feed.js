import express from "express";
import { q } from "../db.js";
import { requireAuth } from "../middleware/auth.js";
import { attachVerifications } from "./posts.js";

const router = express.Router();

// GET /api/feed — posts from people you follow, newest first.
// Falls back to trending (most-liked/verified recent) posts if you follow no one.
router.get("/", requireAuth, async (req, res) => {
  const following = await q(
    `SELECT p.*, u.username, u.name, u.current_streak, u.streak_tier, u.sting_score,
            (SELECT COUNT(*)::int FROM post_likes pl WHERE pl.post_id = p.id) AS likes
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE p.user_id IN (SELECT following_id FROM follows WHERE follower_id = $1)
     ORDER BY p.created_at DESC
     LIMIT 50`,
    [req.userId]
  );

  if (following.rows.length) {
    const enriched = await attachVerifications(following.rows, req.userId);
    return res.json({ source: "following", posts: enriched });
  }

  const trending = await q(
    `SELECT p.*, u.username, u.name, u.current_streak, u.streak_tier, u.sting_score,
            (SELECT COUNT(*)::int FROM post_likes pl WHERE pl.post_id = p.id) AS likes
     FROM posts p
     JOIN users u ON u.id = p.user_id
     WHERE p.created_at > now() - interval '3 days'
     ORDER BY p.created_at DESC
     LIMIT 50`
  );
  const enriched = await attachVerifications(trending.rows, req.userId);
  res.json({ source: "trending", posts: enriched });
});

export default router;

