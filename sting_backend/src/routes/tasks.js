import express from "express";
import { q } from "../db.js";

const router = express.Router();

export const CATEGORIZED_POOL = [
  { label: "Read 10 pages of a book", category: "Learning" },
  { label: "Watch today's sunrise or sunset", category: "Nature" },
  { label: "A small act of kindness in progress", category: "Kindness" },
  { label: "Drink 3 liters of water — show your bottle", category: "Fitness" },
  { label: "One set or rep you almost skipped", category: "Fitness" },
  { label: "Spend 30 minutes offline — show your view", category: "Mental Health" },
  { label: "Review your expenses & write one budget goal", category: "Finance" },
  { label: "Sketch, write, or create one thing from scratch", category: "Creativity" },
  { label: "Capture natural light with no filter", category: "Photography" },
  { label: "Show your focused workspace right now", category: "Productivity" },
  { label: "Pick up 5 pieces of litter outside", category: "Kindness" },
  { label: "Call your parents or a mentor", category: "Kindness" },
  { label: "Learn one new word & write it by hand", category: "Learning" },
  { label: "Walk 5000 steps — capture your trail", category: "Fitness" },
];

// GET /api/tasks/today — same task for everyone on a given date with window countdown
router.get("/today", async (req, res) => {
  const now = new Date();
  const today = now.toISOString().slice(0, 10);

  // Compute midnight expiry for today
  const midnight = new Date(now);
  midnight.setHours(23, 59, 59, 999);
  const secondsRemaining = Math.max(0, Math.floor((midnight - now) / 1000));

  const existing = await q("SELECT label, category FROM daily_tasks WHERE task_date = $1", [today]);
  if (existing.rows.length) {
    return res.json({
      date: today,
      label: existing.rows[0].label,
      category: existing.rows[0].category || "Productivity",
      windowOpensAt: "07:00:00",
      windowClosesAt: "23:59:59",
      secondsRemaining,
    });
  }

  const dayOfMonth = new Date(today).getDate();
  const item = CATEGORIZED_POOL[dayOfMonth % CATEGORIZED_POOL.length];

  await q(
    "INSERT INTO daily_tasks (task_date, label, category) VALUES ($1, $2, $3) ON CONFLICT (task_date) DO NOTHING",
    [today, item.label, item.category]
  );

  res.json({
    date: today,
    label: item.label,
    category: item.category,
    windowOpensAt: "07:00:00",
    windowClosesAt: "23:59:59",
    secondsRemaining,
  });
});

export default router;

