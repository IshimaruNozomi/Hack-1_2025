from pydantic import BaseModel

class LikeCreate(BaseModel):
    post_id: int
    user_id: str
