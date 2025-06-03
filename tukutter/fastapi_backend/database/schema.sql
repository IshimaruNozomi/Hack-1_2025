from pydantic import BaseModel
from datetime import datetime

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

CREATE TABLE IF NOT EXISTS likes (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    user_id TEXT NOT NULL,
    UNIQUE (post_id, user_id)
);

CREATE TABLE comment (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE follows (
  follower_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  followed_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (follower_id, followed_id)
);


class CommentCreate(BaseModel):
    post_id: int
    user_id: int
    content: str

class CommentRead(BaseModel):
    id: int
    post_id: int
    user_id: int
    content: str
    created_at: datetime

    class Config:
        orm_mode = True