/**
 * Returns the tier name for a given streak count.
 * Milestones:
 * - 7 Days   → Bronze
 * - 30 Days  → Silver
 * - 100 Days → Gold
 * - 365 Days → Diamond
 * - 1000 Days → Legend
 */
export function getStreakTier(streak) {
  if (streak >= 1000) return "Legend";
  if (streak >= 365) return "Diamond";
  if (streak >= 100) return "Gold";
  if (streak >= 30) return "Silver";
  if (streak >= 7) return "Bronze";
  return "None";
}

/**
 * Given a user's last_post_date, current streak, and available freeze passes,
 * compute the updated streak for a new post happening "today".
 * If user missed exactly 1 day (diffDays === 2) and has a freeze pass,
 * streak is preserved and freezePassUsed is flagged!
 */
export function nextStreak({ lastPostDate, currentStreak, freezePasses = 0 }) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  if (!lastPostDate) {
    const streak = 1;
    return { streak, tier: getStreakTier(streak), alreadyPostedToday: false, freezePassUsed: false };
  }

  const last = new Date(lastPostDate);
  last.setHours(0, 0, 0, 0);

  const diffDays = Math.round((today - last) / (1000 * 60 * 60 * 24));

  if (diffDays === 0) {
    return {
      streak: currentStreak,
      tier: getStreakTier(currentStreak),
      alreadyPostedToday: true,
      freezePassUsed: false,
    };
  }
  if (diffDays === 1) {
    const streak = currentStreak + 1;
    return {
      streak,
      tier: getStreakTier(streak),
      alreadyPostedToday: false,
      freezePassUsed: false,
    };
  }

  // If exactly 1 day missed and user has a freeze pass, preserve the streak!
  if (diffDays === 2 && freezePasses > 0) {
    const streak = currentStreak + 1;
    return {
      streak,
      tier: getStreakTier(streak),
      alreadyPostedToday: false,
      freezePassUsed: true,
    };
  }

  // Missed window with no freeze pass -> resets to 1
  const streak = 1;
  return {
    streak,
    tier: getStreakTier(streak),
    alreadyPostedToday: false,
    freezePassUsed: false,
  };
}

/**
 * Real Reputation: Sting Score (0 - 1000)
 * Evaluates authenticity, consistency, and community peer trust:
 * + Streak points (2.5 per day, capped at 300)
 * + Verified reactions received (+5 each)
 * + Inspiring reactions received (+8 each)
 * + Active verifications given to others (+2 each)
 * - Needs Review penalty (-25 each)
 */
export function calculateStingScore({
  streak = 0,
  verifiedCount = 0,
  inspiringCount = 0,
  reviewCount = 0,
  verificationsGiven = 0,
}) {
  const base = 100;
  const streakPoints = Math.min(300, Math.floor(streak * 2.5));
  const trustPoints = verifiedCount * 5 + inspiringCount * 8;
  const engagementPoints = Math.min(100, verificationsGiven * 2);
  const penalty = reviewCount * 25;

  const rawScore = base + streakPoints + trustPoints + engagementPoints - penalty;
  return Math.max(10, Math.min(1000, rawScore));
}

