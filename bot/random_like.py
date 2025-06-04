import requests
import random

# 認証トークン（実際のトークンに置き換えてください）
headers = {
    "Authorization": "Bearer YOUR_TOKEN"
}

# 投稿一覧を取得
response = requests.get("ここ多分エンドポイントかな？", headers=headers)
if response.status_code != 200:
    print("投稿の取得に失敗しました")
    exit()

posts = response.json()

# 投稿が3件未満の場合に備えた対応
num_likes = min(3, len(posts))

# ランダムに投稿を選び「いいね」する
for post in random.sample(posts, k=num_likes):
    post_id = post["id"]
    #like_url = f"https://yourapp.com/api/posts/{post_id}/like"
    res = requests.post(like_url, headers=headers)
    print(f"Liked post {post_id}: {res.status_code}")
