CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id TEXT,
    content TEXT,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_profiles (
  user_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  bio TEXT DEFAULT '',
  icon_url TEXT DEFAULT ''
);
