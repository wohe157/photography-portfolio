import os

from flask import Flask, jsonify
from flask_cors import CORS


app = Flask(__name__)
CORS(app)
PHOTO_ROOT = '/media'


@app.route('/api/gallery')
def api_gallery():
    groups = []
    for group_name in sorted(os.listdir(PHOTO_ROOT)):
        group_path = os.path.join(PHOTO_ROOT, group_name)
        if os.path.isdir(group_path):
            images = sorted([
                f for f in os.listdir(group_path)
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.webp'))
            ])
            groups.append({
                'name': group_name,
                'title': group_name.capitalize(),
                'images': images
            })
    return jsonify({'groups': groups})

if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=True)
