-- Phase 4 Migration: Streak Tiers, Community Verification, Sting Score, and Freeze Passes

-- Add columns to users if they don't exist
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS sting_score INT DEFAULT 100,
  ADD COLUMN IF NOT EXISTS freeze_passes INT DEFAULT 1,
  ADD COLUMN IF NOT EXISTS last_freeze_date DATE,
  ADD COLUMN IF NOT EXISTS streak_tier TEXT DEFAULT 'None';

-- Add category and expiration to daily_tasks
ALTER TABLE daily_tasks
  ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Productivity',
  ADD COLUMN IF NOT EXISTS window_opens_at TIME DEFAULT '07:00:00',
  ADD COLUMN IF NOT EXISTS window_closes_at TIME DEFAULT '23:59:59';

-- Community verification reactions (replaces vanity likes with peer accountability)
CREATE TABLE IF NOT EXISTS post_verifications (
  post_id     INT REFERENCES posts(id) ON DELETE CASCADE,
  user_id     INT REFERENCES users(id) ON DELETE CASCADE,
  reaction    TEXT NOT NULL CHECK (reaction IN ('verified', 'inspiring', 'needs_review')),
  created_at  TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_verifications_post ON post_verifications(post_id);
CREATE INDEX IF NOT EXISTS idx_verifications_user ON post_verifications(user_id);
