import requests
import random

def get_firebase_token(email, password):
    firebase_api_key = "AIzaSyC3s8xHONDAd27PFcnrlOuV9E2ktzQig3U"  # ← FirebaseのWeb APIキーをここに入れてください
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={firebase_api_key}"

    payload = {
        "email": email,
        "password": password,
        "returnSecureToken": True
    }

    response = requests.post(url, json=payload)
    if response.status_code == 200:
        return response.json()["idToken"]
    else:
        print("Firebaseログインに失敗しました:", response.text)
        exit()

def main():
    # bot用ユーザーのメールとパスワード（Firebase Authenticationに登録済みのもの）
    email = "bot@example.com"
    password = "200404Seven"

    # Firebase認証してIDトークンを取得
    token = get_firebase_token(email, password)

    # AuthorizationヘッダーにIDトークンをセット
    headers = {
        "Authorization": f"Bearer {token}"
    }

    # 投稿一覧を取得
    response = requests.get("http://localhost:8000/posts", headers=headers)
    if response.status_code != 200:
        print("投稿の取得に失敗しました:", response.status_code, response.text)
        exit()

    posts = response.json()

    # 投稿が3件未満の場合にも対応
    num_likes = min(3, len(posts))

    # ランダムに投稿を選んで「いいね」する
    for post in random.sample(posts, k=num_likes):
        post_id = post["id"]
        like_url = f"http://localhost:8000/posts/{post_id}/like"  # 実際のlikeエンドポイントに合わせて修正
        res = requests.post(like_url, headers=headers)
        print(f"Liked post {post_id}: {res.status_code}")

if __name__ == "__main__":
    main()
