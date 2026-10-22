-- Sting — Phase 1-3 schema

CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  email         TEXT UNIQUE,
  phone         TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  username      TEXT UNIQUE NOT NULL,
  name          TEXT DEFAULT '',
  bio           TEXT DEFAULT '',
  interest      TEXT DEFAULT '',
  avatar_url    TEXT,
  is_private    BOOLEAN DEFAULT FALSE,
  is_verified   BOOLEAN DEFAULT FALSE,
  current_streak   INT DEFAULT 0,
  longest_streak   INT DEFAULT 0,
  streak_tier      TEXT DEFAULT 'None',
  sting_score      INT DEFAULT 100,
  freeze_passes    INT DEFAULT 1,
  last_freeze_date DATE,
  last_post_date   DATE,
  created_at       TIMESTAMPTZ DEFAULT now()
);

-- Upgrade existing users table if it was created in Phase 1
ALTER TABLE users ADD COLUMN IF NOT EXISTS streak_tier TEXT DEFAULT 'None';
ALTER TABLE users ADD COLUMN IF NOT EXISTS sting_score INT DEFAULT 100;
ALTER TABLE users ADD COLUMN IF NOT EXISTS freeze_passes INT DEFAULT 1;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_freeze_date DATE;

CREATE TABLE IF NOT EXISTS otp_codes (
  id         SERIAL PRIMARY KEY,
  contact    TEXT NOT NULL,          -- email or phone this code was sent to
  code       TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used       BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS follows (
  follower_id  INT REFERENCES users(id) ON DELETE CASCADE,
  following_id INT REFERENCES users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);

CREATE TABLE IF NOT EXISTS daily_tasks (
  id               SERIAL PRIMARY KEY,
  task_date        DATE UNIQUE NOT NULL,
  label            TEXT NOT NULL,
  category         TEXT DEFAULT 'Productivity',
  window_opens_at  TIME DEFAULT '07:00:00',
  window_closes_at TIME DEFAULT '23:59:59'
);

ALTER TABLE daily_tasks ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Productivity';
ALTER TABLE daily_tasks ADD COLUMN IF NOT EXISTS window_opens_at TIME DEFAULT '07:00:00';
ALTER TABLE daily_tasks ADD COLUMN IF NOT EXISTS window_closes_at TIME DEFAULT '23:59:59';

CREATE TABLE IF NOT EXISTS posts (
  id             SERIAL PRIMARY KEY,
  user_id        INT REFERENCES users(id) ON DELETE CASCADE,
  task_label     TEXT NOT NULL,
  caption        TEXT DEFAULT '',
  image_url      TEXT,
  verified_live  BOOLEAN DEFAULT FALSE,
  captured_at    TIMESTAMPTZ NOT NULL,
  created_at     TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS post_likes (
  post_id    INT REFERENCES posts(id) ON DELETE CASCADE,
  user_id    INT REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

CREATE TABLE IF NOT EXISTS post_verifications (
  post_id     INT REFERENCES posts(id) ON DELETE CASCADE,
  user_id     INT REFERENCES users(id) ON DELETE CASCADE,
  reaction    TEXT NOT NULL CHECK (reaction IN ('verified', 'inspiring', 'needs_review')),
  created_at  TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

CREATE TABLE IF NOT EXISTS friend_challenges (
  id              SERIAL PRIMARY KEY,
  challenger_id   INT REFERENCES users(id) ON DELETE CASCADE,
  challengee_id   INT REFERENCES users(id) ON DELETE CASCADE,
  task_label      TEXT NOT NULL,
  challenger_done BOOLEAN DEFAULT FALSE,
  challengee_done BOOLEAN DEFAULT FALSE,
  expires_at      TIMESTAMPTZ NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id);
CREATE INDEX IF NOT EXISTS idx_verifications_post ON post_verifications(post_id);
CREATE INDEX IF NOT EXISTS idx_verifications_user ON post_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_challenges_participants ON friend_challenges(challenger_id, challengee_id);

