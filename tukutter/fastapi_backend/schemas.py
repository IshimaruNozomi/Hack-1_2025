# schemas.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# 投稿に対する「いいね」作成用
class LikeCreate(BaseModel):
    post_id: int
    user_id: str

# コメント作成用
class CommentCreate(BaseModel):
    post_id: int
    user_id: int
    content: str

# コメント読み取り用
class CommentRead(BaseModel):
    id: int
    post_id: int
    user_id: int
    content: str
    created_at: datetime

    class Config:
        orm_mode = True

# フォロー関係作成用
class FollowCreate(BaseModel):
    follower_id: int
    followed_id: int

# 投稿作成用（必要に応じて）
class PostCreate(BaseModel):
    user_id: str
    content: Optional[str] = None
    image_url: Optional[str] = None

# 投稿読み取り用
class PostRead(BaseModel):
    id: int
    user_id: str
    content: Optional[str]
    image_url: Optional[str]
    created_at: datetime

    class Config:
        orm_mode = True

# ユーザープロフィール用
class UserProfile(BaseModel):
    user_id: str
    name: str
    bio: Optional[str] = ''
    icon_url: Optional[str] = ''

    class Config:
        orm_mode = True
