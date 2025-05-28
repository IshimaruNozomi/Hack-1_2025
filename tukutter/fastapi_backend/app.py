from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2

app = FastAPI()

class Post(BaseModel):
    user_id: str
    content: str
    image_url: str  # Cloudinaryから返ってくる画像URLを受け取る

@app.post("/create_post")
def create_post(post: Post):
    conn = psycopg2.connect("dbname=yourdb user=youruser password=yourpass host=localhost port=5432")
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO posts (user_id, content, image_url) VALUES (%s, %s, %s)",
        (post.user_id, post.content, post.image_url)
    )
    conn.commit()
    cur.close()
    conn.close()
    return {"message": "投稿完了"}
