import express from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";
import { q } from "../db.js";
import { requireAuth } from "../middleware/auth.js";
import { nextStreak, calculateStingScore } from "../utils/streak.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, "..", "..", "uploads")),
  filename: (req, file, cb) => cb(null, `${req.userId}_${Date.now()}${path.extname(file.originalname)}`),
});
const upload = multer({
  storage,
  limits: { fileSize: 12 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    // Unfiltered accepts only camera-captured images the client sends as
    // multipart form data — this endpoint has no notion of "pick from
    // gallery"; that enforcement lives client-side in the capture flow.
    if (!file.mimetype.startsWith("image/")) return cb(new Error("Only image uploads are accepted."));
    cb(null, true);
  },
});

// POST /api/posts  (multipart: image, taskLabel, caption, verifiedLive, capturedAt)
router.post("/", requireAuth, upload.single("image"), async (req, res) => {
  const { taskLabel, caption, verifiedLive, capturedAt } = req.body;
  if (!taskLabel) return res.status(400).json({ error: "taskLabel is required." });

  const userResult = await q(
    "SELECT last_post_date, current_streak, longest_streak, freeze_passes, sting_score FROM users WHERE id = $1",
    [req.userId]
  );
  const user = userResult.rows[0];
  const { streak, tier, alreadyPostedToday, freezePassUsed } = nextStreak({
    lastPostDate: user.last_post_date,
    currentStreak: user.current_streak,
    freezePasses: user.freeze_passes,
  });

  if (alreadyPostedToday) {
    return res.status(409).json({ error: "You've already posted today's Unfiltered. Come back tomorrow." });
  }

  const longest = Math.max(streak, user.longest_streak);
  const newFreezePasses = freezePassUsed ? Math.max(0, user.freeze_passes - 1) : user.freeze_passes;
  const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

  const inserted = await q(
    `INSERT INTO posts (user_id, task_label, caption, image_url, verified_live, captured_at)
     VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [req.userId, taskLabel, caption || "", imageUrl, verifiedLive === "true" || verifiedLive === true, capturedAt || new Date()]
  );

  // Re-estimate Sting Score with new streak
  const newScore = Math.min(1000, (user.sting_score || 100) + 15);

  await q(
    `UPDATE users 
     SET current_streak = $1, longest_streak = $2, streak_tier = $3, 
         freeze_passes = $4, sting_score = $5, last_post_date = CURRENT_DATE 
     WHERE id = $6`,
    [streak, longest, tier, newFreezePasses, newScore, req.userId]
  );

  res.status(201).json({
    post: inserted.rows[0],
    currentStreak: streak,
    longestStreak: longest,
    streakTier: tier,
    freezePasses: newFreezePasses,
    stingScore: newScore,
    freezePassUsed,
  });
});

// Helper to attach verification stats to posts
async function attachVerifications(posts, currentUserId) {
  if (!posts.length) return [];
  const postIds = posts.map((p) => p.id);

  const statsRes = await q(
    `SELECT post_id,
            COUNT(*) FILTER (WHERE reaction = 'verified')::int AS verified_count,
            COUNT(*) FILTER (WHERE reaction = 'inspiring')::int AS inspiring_count,
            COUNT(*) FILTER (WHERE reaction = 'needs_review')::int AS review_count
     FROM post_verifications
     WHERE post_id = ANY($1)
     GROUP BY post_id`,
    [postIds]
  );

  const myReactionsRes = currentUserId
    ? await q(
        `SELECT post_id, reaction FROM post_verifications WHERE user_id = $1 AND post_id = ANY($2)`,
        [currentUserId, postIds]
      )
    : { rows: [] };

  const statsMap = new Map(statsRes.rows.map((r) => [r.post_id, r]));
  const myMap = new Map(myReactionsRes.rows.map((r) => [r.post_id, r.reaction]));

  return posts.map((p) => {
    const s = statsMap.get(p.id) || { verified_count: 0, inspiring_count: 0, review_count: 0 };
    return {
      ...p,
      verifiedCount: s.verified_count,
      inspiringCount: s.inspiring_count,
      reviewCount: s.review_count,
      myReaction: myMap.get(p.id) || null,
    };
  });
}

// GET /api/posts/me
router.get("/me", requireAuth, async (req, res) => {
  const result = await q("SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC", [req.userId]);
  const enriched = await attachVerifications(result.rows, req.userId);
  res.json(enriched);
});

// POST /api/posts/:id/verify  (Peer Community Verification)
// Body: { reaction: 'verified' | 'inspiring' | 'needs_review' }
router.post("/:id/verify", requireAuth, async (req, res) => {
  const { reaction } = req.body;
  if (!["verified", "inspiring", "needs_review"].includes(reaction)) {
    return res.status(400).json({ error: "Reaction must be 'verified', 'inspiring', or 'needs_review'." });
  }

  const postId = req.params.id;

  // Insert or update peer reaction
  await q(
    `INSERT INTO post_verifications (post_id, user_id, reaction)
     VALUES ($1, $2, $3)
     ON CONFLICT (post_id, user_id) DO UPDATE SET reaction = EXCLUDED.reaction, created_at = now()`,
    [postId, req.userId, reaction]
  );

  // Find post author and update their Sting Score
  const authorRes = await q("SELECT user_id FROM posts WHERE id = $1", [postId]);
  if (authorRes.rows.length) {
    const authorId = authorRes.rows[0].user_id;

    const countRes = await q(
      `SELECT COUNT(*) FILTER (WHERE reaction = 'verified')::int AS v_count,
              COUNT(*) FILTER (WHERE reaction = 'inspiring')::int AS i_count,
              COUNT(*) FILTER (WHERE reaction = 'needs_review')::int AS r_count
       FROM post_verifications pv
       JOIN posts p ON p.id = pv.post_id
       WHERE p.user_id = $1`,
      [authorId]
    );

    const userRes = await q("SELECT current_streak FROM users WHERE id = $1", [authorId]);
    const counts = countRes.rows[0] || {};
    const newAuthorScore = calculateStingScore({
      streak: userRes.rows[0]?.current_streak || 0,
      verifiedCount: counts.v_count || 0,
      inspiringCount: counts.i_count || 0,
      reviewCount: counts.r_count || 0,
    });

    await q("UPDATE users SET sting_score = $1 WHERE id = $2", [newAuthorScore, authorId]);
  }

  // Get updated counts for this post
  const counts = await q(
    `SELECT COUNT(*) FILTER (WHERE reaction = 'verified')::int AS verified_count,
            COUNT(*) FILTER (WHERE reaction = 'inspiring')::int AS inspiring_count,
            COUNT(*) FILTER (WHERE reaction = 'needs_review')::int AS review_count
     FROM post_verifications WHERE post_id = $1`,
    [postId]
  );

  res.json({
    verifiedCount: counts.rows[0].verified_count,
    inspiringCount: counts.rows[0].inspiring_count,
    reviewCount: counts.rows[0].review_count,
    myReaction: reaction,
  });
});

// DELETE /api/posts/:id/verify
router.delete("/:id/verify", requireAuth, async (req, res) => {
  const postId = req.params.id;
  await q("DELETE FROM post_verifications WHERE post_id = $1 AND user_id = $2", [postId, req.userId]);

  const counts = await q(
    `SELECT COUNT(*) FILTER (WHERE reaction = 'verified')::int AS verified_count,
            COUNT(*) FILTER (WHERE reaction = 'inspiring')::int AS inspiring_count,
            COUNT(*) FILTER (WHERE reaction = 'needs_review')::int AS review_count
     FROM post_verifications WHERE post_id = $1`,
    [postId]
  );

  res.json({
    verifiedCount: counts.rows[0].verified_count,
    inspiringCount: counts.rows[0].inspiring_count,
    reviewCount: counts.rows[0].review_count,
    myReaction: null,
  });
});

// POST /api/posts/:id/like
router.post("/:id/like", requireAuth, async (req, res) => {
  await q("INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", [
    req.params.id,
    req.userId,
  ]);
  const count = await q("SELECT COUNT(*)::int AS n FROM post_likes WHERE post_id = $1", [req.params.id]);
  res.json({ liked: true, likes: count.rows[0].n });
});

// DELETE /api/posts/:id/like
router.delete("/:id/like", requireAuth, async (req, res) => {
  await q("DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2", [req.params.id, req.userId]);
  const count = await q("SELECT COUNT(*)::int AS n FROM post_likes WHERE post_id = $1", [req.params.id]);
  res.json({ liked: false, likes: count.rows[0].n });
});

export { attachVerifications };
export default router;
