CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id TEXT,
    content TEXT,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
