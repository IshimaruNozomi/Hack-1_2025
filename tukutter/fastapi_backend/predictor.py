import tensorflow as tf
import numpy as np
from PIL import Image

# モデル読み込み
interpreter = tf.lite.Interpreter(model_path="model.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# クラス名（gazou.pyで使用していた順番と合わせる）
class_names = ["カレー", "チャーハン", "ハンバーグ", "その他1", "その他2"]

# 推論関数
def predict_image(img_path):
    image = Image.open(img_path).convert("RGB").resize((180, 180))
    input_data = np.expand_dims(np.array(image, dtype=np.float32) / 255.0, axis=0)

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()

    output_data = interpreter.get_tensor(output_details[0]['index'])
    predicted_index = np.argmax(output_data[0])
    return class_names[predicted_index]
