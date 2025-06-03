from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from database import get_db
from models import User

# トークンを受け取るためのOAuth2PasswordBearer設定（tokenUrlは認証用エンドポイント）
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# 秘密鍵・アルゴリズムは環境変数などで管理すべき
SECRET_KEY = "YOUR_SECRET_KEY"  # 実際はもっと複雑に＆env管理推奨
ALGORITHM = "HS256"

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="認証情報が無効です。",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # JWTトークンのデコード
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # DBからユーザーを取得
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception

    return user
