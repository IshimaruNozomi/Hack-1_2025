from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg2

app = FastAPI()

class Post(BaseModel):
    user_id: str
    content: str
    image_url: str

@app.post("/create_post")
def create_post(post: Post):
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="your_database_name",
            user="your_user",
            password="your_password",
            port=5432
        )
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO posts (user_id, content, image_url) VALUES (%s, %s, %s)",
            (post.user_id, post.content, post.image_url)
        )
        conn.commit()
        cur.close()
        conn.close()
        return {"message": "投稿完了"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DBエラー: {e}")
