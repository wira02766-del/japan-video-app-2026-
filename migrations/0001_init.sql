
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  google_sub TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  premium_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (premium_status IN ('pending','approved','revoked')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS media_items (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('video','short','photo','premium')),
  visibility TEXT NOT NULL CHECK (visibility IN ('public','premium')),
  category TEXT,
  description TEXT,
  object_key TEXT NOT NULL,
  content_type TEXT NOT NULL,
  size_bytes INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'active',
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS posts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  body TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS advertisements (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  creative_type TEXT NOT NULL DEFAULT 'text',
  creative_url TEXT,
  target_url TEXT,
  placements TEXT NOT NULL DEFAULT 'all',
  audience TEXT NOT NULL DEFAULT 'all',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS telegram_events (
  id TEXT PRIMARY KEY,
  chat_id TEXT,
  message_id TEXT,
  text TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS admin_logs (
  id TEXT PRIMARY KEY,
  admin_user_id TEXT,
  action TEXT NOT NULL,
  target_id TEXT,
  details TEXT,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_media_visibility_type_status
ON media_items(visibility, type, status, created_at);

CREATE INDEX IF NOT EXISTS idx_posts_status_created
ON posts(status, created_at);

CREATE INDEX IF NOT EXISTS idx_users_premium_status
ON users(premium_status, created_at);

CREATE INDEX IF NOT EXISTS idx_ads_active_created
ON advertisements(is_active, created_at);
