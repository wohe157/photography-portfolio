import json
import os

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["MEDIA_BUCKET"]


def lambda_handler(event, context):
    top_level = s3.list_objects_v2(Bucket=BUCKET, Prefix="media/", Delimiter="/")

    groups = []
    for prefix in top_level.get("CommonPrefixes", []):
        full_prefix = prefix["Prefix"]
        group = full_prefix.split("/")[1]

        image_resp = s3.list_objects_v2(Bucket=BUCKET, Prefix=full_prefix)

        images = [
            obj["Key"].split("/")[-1]
            for obj in image_resp.get("Contents", [])
            if obj["Key"].lower().endswith((".jpg", ".jpeg", ".png", ".gif", ".webp"))
        ]

        groups.append({"name": group, "title": group.capitalize(), "images": images})

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,OPTIONS",
            "Access-Control-Allow-Headers": "*",
        },
        "body": json.dumps({"groups": groups}),
    }
