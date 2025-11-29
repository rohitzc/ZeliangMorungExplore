#!/usr/bin/env python3
"""
Advanced AI Image Enhancement Script
Enhances images to look very scenic, bright, and HD using advanced AI techniques
"""

import os
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageOps, ImageDraw
import numpy as np

# Try to import OpenCV for advanced processing
try:
    import cv2
    OPENCV_AVAILABLE = True
except ImportError:
    OPENCV_AVAILABLE = False
    print("Warning: OpenCV not available. Install with: pip install opencv-python")
    print("Falling back to PIL-only enhancement (still very good!)")

def create_smooth_shading_mask(height, width, center_focus=True):
    """
    Create a smooth shading mask for tonal adjustments
    """
    y, x = np.ogrid[:height, :width]
    if center_focus:
        # Radial gradient from center
        center_x, center_y = width // 2, height // 2
        mask = np.sqrt((x - center_x)**2 + (y - center_y)**2)
        max_dist = np.sqrt(center_x**2 + center_y**2)
        mask = 1 - (mask / max_dist) * 0.3  # 30% darker at edges
    else:
        # Linear gradient from top
        mask = 1 - (y / height) * 0.2  # 20% darker at bottom
    return np.clip(mask, 0.7, 1.0)

def apply_vignette_effect(img_array, strength=0.15):
    """
    Apply smooth vignette effect for artistic look
    """
    height, width = img_array.shape[:2]
    y, x = np.ogrid[:height, :width]
    center_x, center_y = width // 2, height // 2
    
    # Create radial mask
    mask = np.sqrt((x - center_x)**2 + (y - center_y)**2)
    max_dist = np.sqrt(center_x**2 + center_y**2)
    vignette = 1 - (mask / max_dist) * strength
    vignette = np.clip(vignette, 0.85, 1.0)
    
    # Apply vignette to each channel
    if len(img_array.shape) == 3:
        vignette = vignette[:, :, np.newaxis]
    
    return (img_array * vignette).astype(np.uint8)

def apply_glow_effect(img_array, intensity=0.1):
    """
    Apply subtle glow effect for dreamy look
    """
    if OPENCV_AVAILABLE:
        # Create soft glow using Gaussian blur
        blurred = cv2.GaussianBlur(img_array, (0, 0), 15)
        # Blend original with blurred version
        glowed = cv2.addWeighted(img_array, 1 - intensity, blurred, intensity, 0)
        return glowed
    return img_array

def enhance_image_advanced(image_path, output_path):
    """
    Advanced AI-powered image enhancement with smooth shading and effects
    """
    try:
        # Read image
        if OPENCV_AVAILABLE:
            img_bgr = cv2.imread(str(image_path))
            if img_bgr is None:
                return False
            
            height, width = img_bgr.shape[:2]
            
            # Convert BGR to RGB for processing
            img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB).astype(np.float32)
            
            # Convert to LAB color space for better color manipulation
            lab = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2LAB)
            l, a, b = cv2.split(lab)
            
            # Advanced CLAHE for brightness and contrast with smooth transitions
            clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
            l_enhanced = clahe.apply(l)
            
            # Merge LAB channels
            lab_enhanced = cv2.merge([l_enhanced, a, b])
            img_enhanced = cv2.cvtColor(lab_enhanced, cv2.COLOR_LAB2BGR)
            
            # Convert to RGB for further processing
            img_rgb = cv2.cvtColor(img_enhanced, cv2.COLOR_BGR2RGB).astype(np.float32)
            
            # Advanced denoising while preserving details
            img_rgb_uint8 = img_rgb.astype(np.uint8)
            img_rgb_uint8 = cv2.fastNlMeansDenoisingColored(
                cv2.cvtColor(img_rgb_uint8, cv2.COLOR_RGB2BGR), 
                None, 5, 5, 7, 21
            )
            img_rgb = cv2.cvtColor(img_rgb_uint8, cv2.COLOR_BGR2RGB).astype(np.float32)
            
            # Smooth shading - apply radial gradient for depth
            shading_mask = create_smooth_shading_mask(height, width, center_focus=True)
            img_rgb = img_rgb * shading_mask[:, :, np.newaxis]
            img_rgb = np.clip(img_rgb, 0, 255)
            
            # Enhance saturation for scenic look
            img_rgb_uint8 = img_rgb.astype(np.uint8)
            hsv = cv2.cvtColor(img_rgb_uint8, cv2.COLOR_RGB2HSV).astype(np.float32)
            h, s, v = cv2.split(hsv)
            
            # Increase saturation by 25% for vibrant scenic look
            s = s * 1.25
            s = np.clip(s, 0, 255)
            # Slightly increase brightness
            v = v * 1.15
            v = np.clip(v, 0, 255)
            hsv_enhanced = cv2.merge([h, s, v]).astype(np.uint8)
            img_rgb = cv2.cvtColor(hsv_enhanced, cv2.COLOR_HSV2RGB).astype(np.float32)
            
            # Apply subtle glow effect
            img_rgb = apply_glow_effect(img_rgb.astype(np.uint8), intensity=0.08).astype(np.float32)
            
            # Advanced sharpening using unsharp mask
            gaussian = cv2.GaussianBlur(img_rgb.astype(np.uint8), (0, 0), 1.5)
            img_rgb = cv2.addWeighted(img_rgb.astype(np.uint8), 1.8, gaussian, -0.8, 0)
            img_rgb = np.clip(img_rgb, 0, 255).astype(np.uint8)
            
            # Apply smooth vignette effect
            img_rgb = apply_vignette_effect(img_rgb, strength=0.12)
            
            # Final smooth shading overlay for depth
            final_shading = create_smooth_shading_mask(height, width, center_focus=True)
            img_rgb = (img_rgb.astype(np.float32) * final_shading[:, :, np.newaxis]).astype(np.uint8)
            
            # Convert back to BGR for saving
            img_final = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)
            
            # Save with high quality
            cv2.imwrite(str(output_path), img_final, [cv2.IMWRITE_JPEG_QUALITY, 98])
            print(f"✓ Enhanced (AI Advanced + Effects): {os.path.basename(image_path)}")
            return True
            
        else:
            # Fallback to PIL with aggressive enhancements
            return enhance_image_pil_advanced(image_path, output_path)
            
    except Exception as e:
        print(f"✗ Error enhancing {image_path}: {str(e)}")
        # Fallback to PIL
        return enhance_image_pil_advanced(image_path, output_path)

def create_gradient_mask_pil(size, center_focus=True):
    """
    Create a smooth gradient mask using PIL
    """
    from PIL import ImageDraw
    
    mask = Image.new('L', size, 255)
    draw = ImageDraw.Draw(mask)
    
    width, height = size
    if center_focus:
        # Radial gradient from center
        center_x, center_y = width // 2, height // 2
        max_radius = int(np.sqrt(center_x**2 + center_y**2))
        
        for y in range(height):
            for x in range(width):
                dist = np.sqrt((x - center_x)**2 + (y - center_y)**2)
                intensity = int(255 * (1 - (dist / max_radius) * 0.3))
                intensity = max(178, min(255, intensity))  # 70-100% range
                mask.putpixel((x, y), intensity)
    else:
        # Linear gradient from top
        for y in range(height):
            intensity = int(255 * (1 - (y / height) * 0.2))
            intensity = max(204, min(255, intensity))  # 80-100% range
            draw.rectangle([(0, y), (width, y+1)], fill=intensity)
    
    return mask

def apply_vignette_pil(img, strength=0.15):
    """
    Apply vignette effect using PIL
    """
    width, height = img.size
    mask = Image.new('L', (width, height), 255)
    
    center_x, center_y = width // 2, height // 2
    max_radius = np.sqrt(center_x**2 + center_y**2)
    
    for y in range(height):
        for x in range(width):
            dist = np.sqrt((x - center_x)**2 + (y - center_y)**2)
            intensity = 1 - (dist / max_radius) * strength
            intensity = max(0.85, min(1.0, intensity))
            mask.putpixel((x, y), int(intensity * 255))
    
    # Apply vignette
    img_array = np.array(img)
    mask_array = np.array(mask) / 255.0
    if len(img_array.shape) == 3:
        mask_array = mask_array[:, :, np.newaxis]
    img_array = (img_array * mask_array).astype(np.uint8)
    return Image.fromarray(img_array)

def enhance_image_pil_advanced(image_path, output_path):
    """
    Advanced PIL-based enhancement with smooth shading and effects
    """
    try:
        
        # Open image
        img = Image.open(image_path)
        
        # Convert to RGB if necessary
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Auto-contrast for better dynamic range
        img = ImageOps.autocontrast(img, cutoff=2)
        
        # Apply smooth shading mask for depth
        shading_mask = create_gradient_mask_pil(img.size, center_focus=True)
        img_array = np.array(img).astype(np.float32)
        mask_array = np.array(shading_mask) / 255.0
        img_array = img_array * mask_array[:, :, np.newaxis]
        img = Image.fromarray(np.clip(img_array, 0, 255).astype(np.uint8))
        
        # Aggressive brightness enhancement for scenic look
        enhancer = ImageEnhance.Brightness(img)
        img = enhancer.enhance(1.25)  # 25% brighter
        
        # Strong contrast enhancement
        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(1.3)  # 30% more contrast
        
        # Vibrant color saturation for scenic look
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(1.35)  # 35% more vibrant
        
        # Apply subtle glow effect using Gaussian blur blend
        img_array = np.array(img).astype(np.float32)
        blurred = np.array(img.filter(ImageFilter.GaussianBlur(radius=3))).astype(np.float32)
        glowed = img_array * 0.92 + blurred * 0.08  # 8% glow
        img = Image.fromarray(np.clip(glowed, 0, 255).astype(np.uint8))
        
        # Strong sharpness enhancement for HD look
        enhancer = ImageEnhance.Sharpness(img)
        img = enhancer.enhance(1.5)  # 50% sharper
        
        # Apply subtle unsharp mask for extra clarity
        img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=150, threshold=3))
        
        # Apply smooth vignette effect
        img = apply_vignette_pil(img, strength=0.12)
        
        # Final smooth shading overlay
        final_shading = create_gradient_mask_pil(img.size, center_focus=True)
        img_array = np.array(img).astype(np.float32)
        final_mask = np.array(final_shading) / 255.0
        img_array = img_array * final_mask[:, :, np.newaxis]
        img = Image.fromarray(np.clip(img_array, 0, 255).astype(np.uint8))
        
        # Save with maximum quality
        img.save(output_path, quality=98, optimize=False, subsampling=0)
        print(f"✓ Enhanced (PIL Advanced + Effects): {os.path.basename(image_path)}")
        return True
        
    except Exception as e:
        print(f"✗ Error enhancing {image_path} with PIL: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def enhance_images_in_directory(directory_path, overwrite=False):
    """
    Enhance all images in a directory with AI-powered techniques
    """
    directory = Path(directory_path)
    if not directory.exists():
        print(f"Directory not found: {directory_path}")
        return
    
    # Supported image extensions
    image_extensions = {'.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG'}
    
    # Get all image files (exclude enhanced folder)
    image_files = [f for f in directory.iterdir() 
                   if f.suffix in image_extensions and f.is_file()
                   and not f.name.startswith('.')]
    
    if not image_files:
        print("No image files found in directory")
        return
    
    print(f"Found {len(image_files)} image(s) to enhance...")
    print("=" * 60)
    print("Applying AI-powered enhancements with effects:")
    print("  • Brightness boost (15-25%)")
    print("  • Contrast enhancement (30%)")
    print("  • Vibrant color saturation (25-35%)")
    print("  • Advanced sharpening for HD clarity")
    print("  • Noise reduction")
    print("  • Scenic color grading")
    print("  • Smooth shading & depth effects")
    print("  • Subtle vignette for artistic look")
    print("  • Soft glow effect for dreamy quality")
    print("=" * 60)
    print()
    
    success_count = 0
    for image_file in image_files:
        if overwrite:
            output_path = image_file
        else:
            # Create backup and enhance
            backup_path = image_file.with_suffix(f'.backup{image_file.suffix}')
            if not backup_path.exists():
                import shutil
                shutil.copy2(image_file, backup_path)
            output_path = image_file
        
        success = enhance_image_advanced(image_file, output_path)
        
        if success:
            success_count += 1
    
    print()
    print("=" * 60)
    print(f"✓ Enhancement complete: {success_count}/{len(image_files)} images enhanced")
    if not overwrite:
        print(f"  Original images backed up with .backup extension")
    print("=" * 60)

if __name__ == "__main__":
    script_dir = Path(__file__).parent
    assets_dir = script_dir / "attached_assets"
    
    print()
    print("=" * 60)
    print("  AI-POWERED IMAGE ENHANCEMENT TOOL")
    print("  Making images scenic, bright, and HD quality")
    print("=" * 60)
    print()
    print(f"Target directory: {assets_dir}")
    print()
    
    if OPENCV_AVAILABLE:
        print("✓ OpenCV available - Using advanced AI techniques")
    else:
        print("⚠ OpenCV not available - Using PIL with aggressive enhancements")
        print("  (Install OpenCV for best results: pip install opencv-python)")
    
    print()
    
    # Ask user if they want to overwrite or create backups
    print("Enhancement mode:")
    print("  • Overwrite original files (faster, no backups)")
    print("  • Create backups (safer, keeps originals)")
    print()
    
    # For automation, we'll create backups by default
    overwrite = False
    
    enhance_images_in_directory(assets_dir, overwrite=overwrite)
    print()
    print("✨ All done! Images are now scenic, bright, and HD quality!")

