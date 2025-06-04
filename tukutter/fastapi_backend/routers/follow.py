from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import User, Follow
from dependencies import get_current_user

router = APIRouter()

@router.post("/follow/{user_id}")
def follow_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if user_id == current_user.id:
        raise HTTPException(status_code=400, detail="自分自身をフォローできません")

    target_user = db.query(User).filter(User.id == user_id).first()
    if not target_user:
        raise HTTPException(status_code=404, detail="対象ユーザーが見つかりません")

    existing_follow = db.query(Follow).filter(
        Follow.follower_id == current_user.id,
        Follow.followed_id == user_id
    ).first()

    if existing_follow:
        raise HTTPException(status_code=400, detail="すでにフォローしています")

    follow = Follow(follower_id=current_user.id, followed_id=user_id)
    db.add(follow)
    db.commit()
    return {"message": "フォローしました"}

@router.delete("/unfollow/{user_id}")
def unfollow_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    follow = db.query(Follow).filter(
        Follow.follower_id == current_user.id,
        Follow.followed_id == user_id
    ).first()

    if not follow:
        raise HTTPException(status_code=404, detail="フォロー関係が見つかりません")

    db.delete(follow)
    db.commit()
    return {"message": "アンフォローしました"}

@router.get("/user/{user_id}/following")
def get_following(user_id: int, db: Session = Depends(get_db)):
    follows = db.query(Follow).filter(Follow.follower_id == user_id).all()
    followed_users = [db.query(User).filter(User.id == f.followed_id).first() for f in follows]
    return [{"id": u.id, "username": u.username} for u in followed_users if u]

@router.get("/user/{user_id}/followers")
def get_followers(user_id: int, db: Session = Depends(get_db)):
    followers = db.query(Follow).filter(Follow.followed_id == user_id).all()
    follower_users = [db.query(User).filter(User.id == f.follower_id).first() for f in followers]
    return [{"id": u.id, "username": u.username} for u in follower_users if u]

@router.get("/search_users")
def search_users(query: str, db: Session = Depends(get_db)):
    users = db.query(User).filter(User.username.ilike(f"%{query}%")).all()
    return [{"id": u.id, "username": u.username} for u in users]
