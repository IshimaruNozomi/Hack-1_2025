# 必要なライブラリのインストール（最初に一度だけ実行）
# pip install tensorflow
# pip install matplotlib
# pip install pillow

import tensorflow as tf
from tensorflow.keras import layers, models
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
import os

# 画像サイズとバッチサイズの設定
image_size = (180, 180)
batch_size = 32

# データセットの読み込み
train_ds = tf.keras.utils.image_dataset_from_directory(
    "/Users/fukasakai/Hack-1_2025/gazou_bunnrui",
    validation_split=0.2,
    subset="training",
    seed=123,
    image_size=image_size,
    batch_size=batch_size
)

val_ds = tf.keras.utils.image_dataset_from_directory(
    "/Users/fukasakai/Hack-1_2025/gazou_bunnrui",
    validation_split=0.2,
    subset="validation",
    seed=123,
    image_size=image_size,
    batch_size=batch_size
)

# モデル構築
model = models.Sequential([
    layers.Rescaling(1./255, input_shape=(180, 180, 3)),
    layers.Conv2D(16, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Conv2D(32, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Conv2D(64, 3, padding='same', activation='relu'),
    layers.MaxPooling2D(),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dense(5)  # クラス数に応じて変更
])

model.compile(
    optimizer='adam',
    loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['accuracy']
)

# モデルの学習
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=10
)

# モデル保存（通常形式）
model.export("my_model")

# TFLite形式に変換して保存
converter = tf.lite.TFLiteConverter.from_saved_model("my_model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)

# クラス名の取得
class_names = train_ds.class_names

# 画像を分類する関数
def predict_image(img_path):
    img = Image.open(img_path).convert("RGB").resize(image_size)
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    predictions = model.predict(img_array)
    predicted_index = np.argmax(predictions)
    return class_names[predicted_index]

# テスト画像のリスト
test_images = [
    "/Users/fukasakai/Hack-1_2025/test/t_curry.png",
    "/Users/fukasakai/Hack-1_2025/test/t_fried_rice.png",
    "/Users/fukasakai/Hack-1_2025/test/t_hamburg_steak.png"
]

# 推論結果を表示
for img_path in test_images:
    result = predict_image(img_path)
    print(f"{img_path} => 推論結果: {result}")

# 正解ラベルとの比較
test_data = [
    ("/Users/fukasakai/Hack-1_2025/test/t_curry.png", "カレー"),
    ("/Users/fukasakai/Hack-1_2025/test/t_fried_rice.png", "チャーハン"),
    ("/Users/fukasakai/Hack-1_2025/test/t_hamburg_steak.png", "ハンバーグ")
]

correct = 0
for img_path, true_label in test_data:
    predicted = predict_image(img_path)
    print(f"{img_path} => 推論: {predicted}, 正解: {true_label}")
    if predicted == true_label:
        correct += 1

# 正解率計算とコメント
accuracy = correct / len(test_data)
print(f"\n正解率: {accuracy:.2%}")

if accuracy >= 0.7:
    print(f"{predicted}、美味しそうだね！")
else:
    print("それ美味しそうだね！")
