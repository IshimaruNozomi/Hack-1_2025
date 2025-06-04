import requests
import random
from datetime import datetime
import json

# FirebaseのWeb APIキー（Firebaseコンソールから取得）
FIREBASE_API_KEY = "AIzaSyC3s8xHONDAd27PFcnrlOuV9E2ktzQig3U"

# botユーザーのメールアドレス・パスワード
BOT_EMAIL = "botuser@example.com"
BOT_PASSWORD = "200404Seven"

# APIサーバーのベースURL
API_BASE_URL = "http://localhost:8000"

def get_firebase_id_token(email, password, api_key):
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}"
    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True
    }
    res = requests.post(url, data=json.dumps(payload))
    if res.status_code != 200:
        print("Firebase認証失敗:", res.text)
        return None
    id_token = res.json().get("idToken")
    return id_token

def fetch_post_dates(headers):
    res = requests.get(f"{API_BASE_URL}/posts", headers=headers)
    if res.status_code != 200:
        print("投稿取得失敗:", res.text)
        return []
    posts = res.json()
    # 投稿の投稿日時が "created_at" のフィールドに入っている想定
    return [post.get("created_at")[:10] for post in posts if post.get("created_at")]

def get_consecutive_post_days(post_dates):
    if not post_dates:
        return 0
    dates = sorted([datetime.strptime(d, "%Y-%m-%d") for d in post_dates])
    today = datetime.now().date()
    count = 1
    for i in range(len(dates) - 1, 0, -1):
        delta = (dates[i].date() - dates[i - 1].date()).days
        if delta == 1:
            count += 1
        elif delta == 0:
            continue
        else:
            break
    if dates[-1].date() != today:
        return count - 1
    return count

def post_comment(headers, message):
    # コメント投稿エンドポイント例
    url = f"{API_BASE_URL}/comments"
    payload = {"message": message}
    res = requests.post(url, headers=headers, json=payload)
    if res.status_code == 201:
        print("コメント投稿成功:", message)
    else:
        print("コメント投稿失敗:", res.status_code, res.text)

def main():
    id_token = get_firebase_id_token(BOT_EMAIL, BOT_PASSWORD, FIREBASE_API_KEY)
    if not id_token:
        return
    headers = {"Authorization": f"Bearer {id_token}"}

    post_dates = fetch_post_dates(headers)
    days = get_consecutive_post_days(post_dates)
    print(f"{days}日連続で投稿しています！")

    if days <= 0:
        print("連続投稿なし、コメントは投稿しません。")
        return

    # コメント例（連続投稿日数に応じてメッセージを変えることも可能）
    comment_message = f"連続投稿お疲れ様です！現在{days}日連続中です！"
    post_comment(headers, comment_message)

if __name__ == "__main__":
    main()
