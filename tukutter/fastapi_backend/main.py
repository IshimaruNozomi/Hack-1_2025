from fastapi import FastAPI, HTTPException, UploadFile, APIRouter, Depends, File
from fastapi.staticfiles import StaticFiles
from firebase_admin import auth, credentials, initialize_app
from pydantic import BaseModel
from typing import List
from sqlalchemy.orm import Session
from fastapi.responses import JSONResponse
from fastapi_backend import models, schemas
from models import Like, Comment, User
from database import get_db
import psycopg2
import psycopg2.extras
import os
import shutil
import uuid
from routers import user  # 別ルーター（ユーザー系）

# FastAPIインスタンス生成
app = FastAPI()
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Firebase Admin SDK 初期化
cred = credentials.Certificate("tukutter-8008e-firebase-adminsdk-fbsvc-044e51cfb2.json")
initialize_app(cred)

# ファイルアップロードディレクトリ
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# DB設定
DB_CONFIG = {
    "host": "localhost",
    "database": "your_database_name",
    "user": "your_user",
    "password": "your_password",
    "port": 5432
}

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

# Pydantic モデル定義
class LoginRequest(BaseModel):
    id_token: str

class Post(BaseModel):
    user_id: str
    content: str
    image_url: str

class PostOut(Post):
    id: int
    created_at: str

class Profile(BaseModel):
    user_id: str
    name: str
    bio: str = ''
    icon_url: str = ''

# ---------------------------------
# メインルーティング定義
# ---------------------------------

router = APIRouter()

@app.get("/")
def root():
    return {"message": "API is working"}

@app.post("/login")
def login_user(login_request: LoginRequest):
    try:
        decoded_token = auth.verify_id_token(login_request.id_token)
        uid = decoded_token["uid"]
        email = decoded_token.get("email", "")
        name = decoded_token.get("name", "")
        return {"uid": uid, "email": email, "name": name}
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"無効なトークン: {e}")

@app.post("/upload_image")
async def upload_image(file: UploadFile = File(...)):
    try:
        if not file.filename.lower().endswith((".png", ".jpg", ".jpeg", ".gif")):
            raise HTTPException(status_code=400, detail="画像ファイルのみ対応しています")
        extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{extension}"
        file_path = os.path.join(UPLOAD_DIR, unique_filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        image_url = f"/{UPLOAD_DIR}/{unique_filename}"
        return {"image_url": image_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"アップロード失敗: {e}")

@app.post("/create_post")
def create_post(post: Post):
    try:
        conn = get_connection()
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

@app.get("/posts", response_model=List[PostOut])
def get_posts():
    try:
        conn = get_connection()
        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cur.execute("SELECT id, user_id, content, image_url, created_at FROM posts ORDER BY created_at DESC")
        rows = cur.fetchall()
        posts = [
            PostOut(
                id=row["id"],
                user_id=row["user_id"],
                content=row["content"],
                image_url=row["image_url"],
                created_at=row["created_at"].isoformat()
            )
            for row in rows
        ]
        cur.close()
        conn.close()
        return posts
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DBエラー: {e}")

@app.delete("/posts/{post_id}")
def delete_post(post_id: int):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT id FROM posts WHERE id = %s", (post_id,))
        if cur.fetchone() is None:
            raise HTTPException(status_code=404, detail="投稿が見つかりません")
        cur.execute("DELETE FROM posts WHERE id = %s", (post_id,))
        conn.commit()
        cur.close()
        conn.close()
        return {"message": "投稿を削除しました"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"削除中にエラーが発生しました: {e}")

@app.post("/create_profile")
def create_profile(profile: Profile):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO user_profiles (user_id, name, bio, icon_url)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (user_id) DO UPDATE
            SET name = EXCLUDED.name,
                bio = EXCLUDED.bio,
                icon_url = EXCLUDED.icon_url
        """, (profile.user_id, profile.name, profile.bio, profile.icon_url))
        conn.commit()
        cur.close()
        conn.close()
        return {"message": "プロフィール作成/更新完了"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DBエラー: {e}")

@app.get("/profile/{user_id}", response_model=Profile)
def get_profile(user_id: str):
    try:
        conn = get_connection()
        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cur.execute("SELECT * FROM user_profiles WHERE user_id = %s", (user_id,))
        row = cur.fetchone()
        cur.close()
        conn.close()
        if row:
            return Profile(**row)
        else:
            raise HTTPException(status_code=404, detail="プロフィールが見つかりません")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DBエラー: {e}")

@app.put("/update_profile/{user_id}")
def update_profile(user_id: str, profile: Profile):
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
            UPDATE user_profiles
            SET name = %s,
                bio = %s,
                icon_url = %s
            WHERE user_id = %s
        """, (profile.name, profile.bio, profile.icon_url, user_id))
        conn.commit()
        cur.close()
        conn.close()
        return {"message": "プロフィール更新完了"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DBエラー: {e}")

@app.get("/users/{user_id}/posts", response_model=List[PostOut])
def get_user_posts(user_id: str):
    try:
        conn = get_connection()
        cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cur.execute(
            "SELECT id, user_id, content, image_url, created_at FROM posts WHERE user_id = %s ORDER BY created_at DESC",
            (user_id,)
        )
        rows = cur.fetchall()
        posts = [
            PostOut(
                id=row["id"],
                user_id=row["user_id"],
                content=row["content"],
                image_url=row["image_url"],
                created_at=row["created_at"].isoformat()
            )
            for row in rows
        ]
        cur.close()
        conn.close()
        return posts
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DBエラー: {e}")

# ==============================
# likes関連エンドポイント
# ==============================

@router.post("/like")
def like_post(like: schemas.LikeCreate, db: Session = Depends(get_db)):
    existing_like = db.query(Like).filter_by(post_id=like.post_id, user_id=like.user_id).first()
    if existing_like:
        raise HTTPException(status_code=400, detail="既にいいねしています")
    new_like = Like(post_id=like.post_id, user_id=like.user_id)
    db.add(new_like)
    db.commit()
    return {"message": "いいねしました"}

@router.get("/likes/{post_id}")
def get_like_count(post_id: int, db: Session = Depends(get_db)):
    count = db.query(Like).filter_by(post_id=post_id).count()
    return {"post_id": post_id, "likes": count}

# ==============================
# コメント関連エンドポイント
# ==============================

@router.post("/comments", response_model=schemas.CommentRead)
def create_comment(comment: schemas.CommentCreate, db: Session = Depends(get_db)):
    db_comment = models.Comment(**comment.dict())
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment

@router.get("/comments/{post_id}", response_model=List[schemas.CommentRead])
def read_comments(post_id: int, db: Session = Depends(get_db)):
    return db.query(models.Comment).filter(models.Comment.post_id == post_id).order_by(models.Comment.created_at.desc()).all()

@router.delete("/comments/{comment_id}")
def delete_comment(comment_id: int, db: Session = Depends(get_db)):
    comment = db.query(models.Comment).filter(models.Comment.id == comment_id).first()
    if not comment:
        raise HTTPException(status_code=404, detail="コメントが見つかりません")
    db.delete(comment)
    db.commit()
    return {"message": "コメントを削除しました"}

# ==============================
# ユーザー検索
# ==============================

@router.get("/search_users")
def search_users(query: str, db: Session = Depends(get_db)):
    users = db.query(User).filter(User.name.ilike(f"%{query}%")).all()
    return [{"user_id": user.user_id, "name": user.name} for user in users]

# ルーターを登録
app.include_router(router)
app.include_router(user.router)
