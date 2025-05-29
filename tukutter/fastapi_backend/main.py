from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.staticfiles import StaticFiles
from firebase_admin import auth, credentials, initialize_app
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List
import psycopg2
import psycopg2.extras
import os
import shutil
import uuid  # ユニークなファイル名生成用

app = FastAPI()
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Firebase Admin SDK の初期化（1回だけ）
cred = credentials.Certificate("path/to/your/firebase-adminsdk.json")  # ←重要
initialize_app(cred)

class LoginRequest(BaseModel):
    id_token: str

# アップロード先ディレクトリ
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# 投稿データ用のPydanticモデル
class Post(BaseModel):
    user_id: str
    content: str
    image_url: str

# タイムライン表示用の出力モデル（id, created_at 付き）
class PostOut(Post):
    id: int
    created_at: str

# データベース接続情報
DB_CONFIG = {
    "host": "localhost",
    "database": "your_database_name",  # ← 実際のDB名に置き換えてください
    "user": "your_user",               # ← 実際のユーザー名に置き換えてください
    "password": "your_password",       # ← 実際のパスワードに置き換えてください
    "port": 5432
}

def get_connection():
    return psycopg2.connect(**DB_CONFIG)

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

        # 必要ならここでDBにユーザー登録する
        return {"uid": uid, "email": email, "name": name}
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"無効なトークン: {e}")

# 画像アップロードエンドポイント
@app.post("/upload_image")
async def upload_image(file: UploadFile = File(...)):
    try:
        # 拡張子チェック（画像ファイル限定）
        if not file.filename.lower().endswith((".png", ".jpg", ".jpeg", ".gif")):
            raise HTTPException(status_code=400, detail="画像ファイル（png, jpg, jpeg, gif）のみ対応しています")

        # ユニークなファイル名を生成して保存
        extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{extension}"
        file_path = os.path.join(UPLOAD_DIR, unique_filename)

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        image_url = f"/{UPLOAD_DIR}/{unique_filename}"  # フロントで使えるURLパスとして返却
        return {"image_url": image_url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"アップロード失敗: {e}")

# 投稿作成エンドポイント
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

# 投稿一覧取得エンドポイント（タイムライン）
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

# ==============================
# プロフィールモデル
# ==============================
class Profile(BaseModel):
    user_id: str
    name: str
    bio: str = ''
    icon_url: str = ''

# プロフィール作成/更新
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

# プロフィール取得
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

# プロフィール編集
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
