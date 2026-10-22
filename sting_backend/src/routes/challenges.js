import express from "express";
import { q } from "../db.js";
import { requireAuth } from "../middleware/auth.js";

const router = express.Router();

// POST /api/challenges/friend — Challenge a friend to today's task
router.post("/friend", requireAuth, async (req, res) => {
  const { friendUsername, taskLabel } = req.body;
  if (!friendUsername) return res.status(400).json({ error: "friendUsername is required." });

  const friendRes = await q("SELECT id FROM users WHERE username = $1", [friendUsername]);
  if (!friendRes.rows.length) return res.status(404).json({ error: "Friend not found." });

  const friendId = friendRes.rows[0].id;
  if (friendId === req.userId) {
    return res.status(400).json({ error: "You cannot challenge yourself." });
  }

  // Set expiration to midnight tonight
  const midnight = new Date();
  midnight.setHours(23, 59, 59, 999);

  const inserted = await q(
    `INSERT INTO friend_challenges (challenger_id, challengee_id, task_label, expires_at)
     VALUES ($1, $2, $3, $4) RETURNING *`,
    [req.userId, friendId, taskLabel || "Today's Unfiltered Sting", midnight]
  );

  res.status(201).json({
    message: `Challenge sent to @${friendUsername}! Both of you must finish before midnight.`,
    challenge: inserted.rows[0],
  });
});

// GET /api/challenges/active — Get active challenges involving the current user
router.get("/active", requireAuth, async (req, res) => {
  const result = await q(
    `SELECT fc.*,
            u1.username AS challenger_username,
            u2.username AS challengee_username
     FROM friend_challenges fc
     JOIN users u1 ON u1.id = fc.challenger_id
     JOIN users u2 ON u2.id = fc.challengee_id
     WHERE (fc.challenger_id = $1 OR fc.challengee_id = $1)
       AND fc.expires_at > now()
     ORDER BY fc.created_at DESC`,
    [req.userId]
  );
  res.json(result.rows);
});

export default router;
