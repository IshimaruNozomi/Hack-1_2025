from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import User, Follow
from dependencies import get_current_user  # JWT 認証が必要な場合

router = APIRouter()

# フォローする
@router.post("/follow/{user_id}")
def follow_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.id == user_id:
        raise HTTPException(status_code=400, detail="自分自身をフォローすることはできません")

    # 既にフォローしていないか確認
    existing_follow = db.query(Follow).filter_by(follower_id=current_user.id, following_id=user_id).first()
    if existing_follow:
        raise HTTPException(status_code=400, detail="すでにフォローしています")

    # ユーザーの存在確認
    target_user = db.query(User).filter_by(id=user_id).first()
    if not target_user:
        raise HTTPException(status_code=404, detail="ユーザーが見つかりません")

    # フォロー追加
    new_follow = Follow(follower_id=current_user.id, following_id=user_id)
    db.add(new_follow)
    db.commit()
    return {"message": f"{target_user.username} をフォローしました"}

# フォロー解除
@router.delete("/unfollow/{user_id}")
def unfollow_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    follow = db.query(Follow).filter_by(follower_id=current_user.id, following_id=user_id).first()
    if not follow:
        raise HTTPException(status_code=404, detail="フォローしていません")

    db.delete(follow)
    db.commit()
    return {"message": "フォローを解除しました"}

# ユーザーがフォローしているユーザー一覧を取得
@router.get("/user/{user_id}/following")
def get_following(user_id: int, db: Session = Depends(get_db)):
    follows = db.query(Follow).filter_by(follower_id=user_id).all()
    user_ids = [f.following_id for f in follows]
    users = db.query(User).filter(User.id.in_(user_ids)).all()
    return [{"id": u.id, "username": u.username} for u in users]

# ユーザー検索
@router.get("/search_users")
def search_users(query: str, db: Session = Depends(get_db)):
    users = db.query(User).filter(User.username.ilike(f"%{query}%")).all()
    return [{"id": u.id, "username": u.username} for u in users]
