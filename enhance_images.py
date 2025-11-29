#!/usr/bin/env python3
"""
AI Image Enhancement Script
Enhances images using PIL/Pillow and OpenCV for realistic beautification
"""

import os
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter

# Try to import OpenCV, but continue without it if not available
try:
    import cv2
    import numpy as np
    OPENCV_AVAILABLE = True
except ImportError:
    OPENCV_AVAILABLE = False

def enhance_image_pil(image_path, output_path, enhancement_factor=1.2):
    """
    Enhance image using PIL/Pillow for realistic improvements
    """
    try:
        # Open image
        img = Image.open(image_path)
        
        # Convert to RGB if necessary
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Enhance brightness (slightly)
        enhancer = ImageEnhance.Brightness(img)
        img = enhancer.enhance(1.1)
        
        # Enhance contrast
        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(1.15)
        
        # Enhance color saturation (realistic)
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(1.1)
        
        # Enhance sharpness
        enhancer = ImageEnhance.Sharpness(img)
        img = enhancer.enhance(1.2)
        
        # Save enhanced image
        img.save(output_path, quality=95, optimize=True)
        print(f"✓ Enhanced: {os.path.basename(image_path)}")
        return True
    except Exception as e:
        print(f"✗ Error enhancing {image_path}: {str(e)}")
        return False

def enhance_image_opencv(image_path, output_path):
    """
    Enhance image using OpenCV for advanced improvements
    """
    try:
        # Read image
        img = cv2.imread(str(image_path))
        if img is None:
            return False
        
        # Convert to LAB color space for better color enhancement
        lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        
        # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l = clahe.apply(l)
        
        # Merge channels
        lab = cv2.merge([l, a, b])
        img = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)
        
        # Slight denoising
        img = cv2.fastNlMeansDenoisingColored(img, None, 3, 3, 7, 21)
        
        # Enhance sharpness using unsharp mask
        gaussian = cv2.GaussianBlur(img, (0, 0), 2.0)
        img = cv2.addWeighted(img, 1.5, gaussian, -0.5, 0)
        
        # Save enhanced image
        cv2.imwrite(str(output_path), img, [cv2.IMWRITE_JPEG_QUALITY, 95])
        print(f"✓ Enhanced (OpenCV): {os.path.basename(image_path)}")
        return True
    except Exception as e:
        print(f"✗ Error enhancing {image_path} with OpenCV: {str(e)}")
        return False

def enhance_images_in_directory(directory_path, use_opencv=True):
    """
    Enhance all images in a directory
    """
    directory = Path(directory_path)
    if not directory.exists():
        print(f"Directory not found: {directory_path}")
        return
    
    # Supported image extensions
    image_extensions = {'.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG'}
    
    # Create enhanced directory
    enhanced_dir = directory / 'enhanced'
    enhanced_dir.mkdir(exist_ok=True)
    
    # Get all image files
    image_files = [f for f in directory.iterdir() 
                   if f.suffix in image_extensions and f.is_file()]
    
    if not image_files:
        print("No image files found in directory")
        return
    
    print(f"Found {len(image_files)} image(s) to enhance...")
    print("-" * 50)
    
    success_count = 0
    for image_file in image_files:
        output_path = enhanced_dir / image_file.name
        
        if use_opencv:
            success = enhance_image_opencv(image_file, output_path)
        else:
            success = enhance_image_pil(image_file, output_path)
        
        if success:
            success_count += 1
    
    print("-" * 50)
    print(f"Enhancement complete: {success_count}/{len(image_files)} images enhanced")
    print(f"Enhanced images saved to: {enhanced_dir}")

if __name__ == "__main__":
    # Get the directory of this script
    script_dir = Path(__file__).parent
    assets_dir = script_dir / "attached_assets"
    
    print("=" * 50)
    print("AI Image Enhancement Tool")
    print("=" * 50)
    print(f"Enhancing images in: {assets_dir}")
    print()
    
    # Check if OpenCV is available
    use_opencv = OPENCV_AVAILABLE
    if use_opencv:
        print("Using OpenCV for advanced enhancement")
    else:
        print("OpenCV not available, using PIL/Pillow only")
        print("(Install with: pip install opencv-python for better results)")
    
    print()
    enhance_images_in_directory(assets_dir, use_opencv=use_opencv)
    print()
    print("Done!")

