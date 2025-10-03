import boto3
import os
from PIL import Image
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables
THUMBNAIL_SIZE = (
    int(os.getenv('THUMBNAIL_WIDTH', '256')),
    int(os.getenv('THUMBNAIL_HEIGHT', '256'))
)
ORIGINAL_PATH_PREFIX = os.getenv('ORIGINAL_PATH_PREFIX', 'media/original/')
THUMBNAIL_PATH_PREFIX = os.getenv('THUMBNAIL_PATH_PREFIX', 'media/thumbnail/')

def cleanup_temp_files(*file_paths):
    """Clean up temporary files"""
    for file_path in file_paths:
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
        except OSError as e:
            logger.warning(f"Error cleaning up {file_path}: {str(e)}")

def validate_event(event):
    """Validate the input event structure"""
    try:
        return (
            event['Records'][0]['s3']['bucket']['name'],
            event['Records'][0]['s3']['object']['key']
        )
    except (KeyError, IndexError) as e:
        raise ValueError(f"Invalid event structure: {str(e)}")

def lambda_handler(event, context) -> None:
    original_image_path = '/tmp/original_image.jpg'
    thumbnail_image_path = '/tmp/thumbnail_image.jpg'
    
    try:
        # Validate input
        bucket_name, object_key = validate_event(event)
        thumbnail_key = object_key.replace(ORIGINAL_PATH_PREFIX, THUMBNAIL_PATH_PREFIX)
        
        logger.info(f"Creating thumbnail for {object_key} in bucket {bucket_name}")
        
        s3 = boto3.client('s3')
        
        # Download original image
        s3.download_file(bucket_name, object_key, original_image_path)
        
        # Process image
        with Image.open(original_image_path) as img:
            img.thumbnail(THUMBNAIL_SIZE)
            img.save(thumbnail_image_path)
        
        # Upload thumbnail
        s3.upload_file(thumbnail_image_path, bucket_name, thumbnail_key)
        logger.info(f"Successfully created thumbnail: {thumbnail_key}")
        
    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        raise
    except ClientError as e:
        logger.error(f"AWS S3 error: {str(e)}")
        raise
    except (IOError, OSError) as e:
        logger.error(f"Image processing error: {str(e)}")
        raise
    finally:
        cleanup_temp_files(original_image_path, thumbnail_image_path)