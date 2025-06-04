from datetime import datetime

# 例：ユーザーごとの投稿日時リスト（実際はDBから取得）
post_dates = [
    "2025-05-26",
    "2025-05-27",
    "2025-05-28",
    "2025-05-29",
]

def get_consecutive_post_days(post_dates):
    # 日付を datetime 型に変換してソート（古い順）
    dates = sorted([datetime.strptime(d, "%Y-%m-%d") for d in post_dates])
    today = datetime.now().date()

    count = 1
    for i in range(len(dates) - 1, 0, -1):
        delta = (dates[i].date() - dates[i - 1].date()).days
        if delta == 1:
            count += 1
        elif delta == 0:
            continue  # 同じ日付ならスキップ
        else:
            break

    # 今日投稿していない場合は記録を1日引く
    if dates[-1].date() != today:
        return count - 1
    return count

if __name__ == "__main__":
    days = get_consecutive_post_days(post_dates)
    print(f"{days}日連続で投稿しています！")
