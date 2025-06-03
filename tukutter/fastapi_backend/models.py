from sqlalchemy import Column, Integer, String, Text, UniqueConstraint, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func

Base = declarative_base()

class Like(Base):
    __tablename__ = 'likes'

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, nullable=False)
    user_id = Column(String, nullable=False)

    __table_args__ = (UniqueConstraint('post_id', 'user_id', name='unique_like'),)

class Comment(Base):
    __tablename__ = "comment"

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, nullable=False)
    user_id = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
