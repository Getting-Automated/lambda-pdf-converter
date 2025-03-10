import json
import base64
import os
import tempfile
import urllib.request
import subprocess
from pdf2image import convert_from_bytes, convert_from_path
from io import BytesIO
from PIL import Image

def lambda_handler(event, context):
    """
    AWS Lambda function that converts a PDF to multiple individual JPEGs.
    
    Expected input:
    - PDF file content as base64 in the request body
    OR
    - A URL to a PDF file in the request body as {"pdf_url": "https://example.com/file.pdf"}
    
    Returns:
    - Array of base64 encoded JPEG files
    """
    print("Lambda environment:")
    print(f"PATH: {os.environ.get('PATH', 'Not set')}")
    print(f"LD_LIBRARY_PATH: {os.environ.get('LD_LIBRARY_PATH', 'Not set')}")
    
    try:
        result = subprocess.run(["pdftoppm", "-v"], capture_output=True, text=True)
        print(f"pdftoppm version: {result.stderr}")
    except Exception as e:
        print(f"Error checking pdftoppm: {e}")
    
    try:
        if 'body' not in event:
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'error': 'No body found in request'})
            }
        
        pdf_content = None
        pdf_path = None
        
        body = event['body']
        
        if isinstance(body, str):
            try:
                body_json = json.loads(body)
                if isinstance(body_json, dict) and 'pdf_url' in body_json:
                    pdf_url = body_json['pdf_url']
                    pdf_path = "/tmp/input.pdf"
                    print(f"Downloading PDF from URL: {pdf_url}")
                    urllib.request.urlretrieve(pdf_url, pdf_path)
                else:
                    pdf_content = base64.b64decode(body)
            except json.JSONDecodeError:
                pdf_content = base64.b64decode(body)
        else:
            pdf_content = body
        
        with tempfile.TemporaryDirectory() as path:
            if pdf_content:
                temp_pdf = "/tmp/input.pdf"
                with open(temp_pdf, 'wb') as f:
                    f.write(pdf_content)
                pdf_path = temp_pdf
            
            print(f"Converting PDF: {pdf_path}")
            
            images = convert_from_path(
                pdf_path,
                dpi=150,
                output_folder=path,
                fmt='jpeg',
                thread_count=2
            )
            
            print(f"Successfully converted {len(images)} pages")
            
            # Convert each image to base64
            image_array = []
            for i, image in enumerate(images):
                img_buffer = BytesIO()
                image.save(img_buffer, format='JPEG')
                img_buffer.seek(0)
                img_base64 = base64.b64encode(img_buffer.getvalue()).decode('utf-8')
                image_array.append({
                    'filename': f'page_{i+1}.jpg',
                    'content': img_base64,
                    'content_type': 'image/jpeg'
                })
            
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'images': image_array,
                    'total_pages': len(images)
                })
            }
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'error': str(e),
                'details': 'Check CloudWatch logs for more information'
            })
        }