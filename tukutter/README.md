FastAPIサーバーの起動方法

1.main.pyがあるディレクトリに移動　fastapi_backendディレクトリ
2.uvicornコマンドでFastAPIサーバーを起動
uvicorn main:app --reload
（main.pyならmain:app、app.pyならapp:app）
3.起動に成功すると
INFO:     Started server process [xxxx]
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
