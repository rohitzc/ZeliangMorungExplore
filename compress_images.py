#!/usr/bin/env python3
"""
Image Compression Script
Compresses images to reduce file size while maintaining sharpness and clarity
"""

import os
from pathlib import Path
from PIL import Image, ImageOps
import shutil

def get_file_size_mb(file_path):
    """Get file size in MB"""
    return os.path.getsize(file_path) / (1024 * 1024)

def get_file_size_kb(file_path):
    """Get file size in KB"""
    return os.path.getsize(file_path) / 1024

def compress_jpeg(image_path, output_path, quality=85, max_dimension=None):
    """
    Compress JPEG image while maintaining quality
    """
    try:
        img = Image.open(image_path)
        
        # Convert to RGB if necessary
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Auto-orient based on EXIF data
        img = ImageOps.exif_transpose(img)
        
        # Resize if max_dimension is specified and image is larger
        if max_dimension:
            width, height = img.size
            if width > max_dimension or height > max_dimension:
                img.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
        
        # Save with optimization
        img.save(
            output_path,
            'JPEG',
            quality=quality,
            optimize=True,
            progressive=True
        )
        return True
    except Exception as e:
        print(f"✗ Error compressing {image_path}: {str(e)}")
        return False

def compress_png(image_path, output_path, quality=85, max_dimension=None):
    """
    Compress PNG image - converts to JPEG for better compression
    or optimizes PNG if transparency is needed
    """
    try:
        img = Image.open(image_path)
        original_output_path = Path(output_path)
        
        # Auto-orient based on EXIF data
        img = ImageOps.exif_transpose(img)
        
        # Check if image has transparency
        has_transparency = img.mode in ('RGBA', 'LA') or 'transparency' in img.info
        
        # Resize if max_dimension is specified and image is larger
        if max_dimension:
            width, height = img.size
            if width > max_dimension or height > max_dimension:
                img.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
        
        if has_transparency:
            # Check if transparency is actually being used
            # If most pixels are opaque, we can flatten to white background and use JPEG
            if img.mode == 'RGBA':
                # Sample pixels to check transparency usage (check every Nth pixel for speed)
                alpha = img.split()[3]
                pixels = list(alpha.getdata())
                step = max(1, len(pixels) // 10000)  # Sample up to 10000 pixels
                transparent_count = sum(1 for i in range(0, len(pixels), step) if pixels[i] < 255)
                total_sampled = len(range(0, len(pixels), step))
                transparency_ratio = transparent_count / total_sampled if total_sampled > 0 else 0
                
                # If less than 5% of pixels are transparent, flatten to white and use JPEG
                if transparency_ratio < 0.05:
                    # Flatten to white background
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    background.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
                    jpeg_path = original_output_path.with_suffix('.jpg')
                    background.save(
                        jpeg_path,
                        'JPEG',
                        quality=quality,
                        optimize=True,
                        progressive=True
                    )
                    return True, jpeg_path
            
            # Keep as PNG but use best compression
            # Try multiple compression strategies and use the smallest
            from io import BytesIO
            best_size = float('inf')
            best_buffer = None
            
            # Strategy 1: Standard RGBA compression
            try:
                buffer = BytesIO()
                img.save(buffer, 'PNG', optimize=True, compress_level=9)
                size = len(buffer.getvalue())
                if size < best_size:
                    best_size = size
                    best_buffer = buffer
            except:
                pass
            
            # Strategy 2: Try quantizing colors if it's RGBA (works well for images with limited colors)
            if img.mode == 'RGBA':
                try:
                    buffer = BytesIO()
                    # Quantize to reduce color palette while preserving transparency
                    img_q = img.quantize(colors=256, method=Image.Quantize.MEDIANCUT)
                    # Convert back to RGBA to preserve transparency
                    img_q = img_q.convert('RGBA')
                    img_q.save(buffer, 'PNG', optimize=True, compress_level=9)
                    size = len(buffer.getvalue())
                    if size < best_size:
                        best_size = size
                        best_buffer = buffer
                except:
                    pass
            
            # Save the best result
            if best_buffer:
                with open(output_path, 'wb') as f:
                    f.write(best_buffer.getvalue())
            else:
                # Fallback
                img.save(output_path, 'PNG', optimize=True, compress_level=9)
            
            return True, original_output_path
        else:
            # Convert to RGB and save as JPEG for better compression
            if img.mode != 'RGB':
                img = img.convert('RGB')
            jpeg_path = original_output_path.with_suffix('.jpg')
            img.save(
                jpeg_path,
                'JPEG',
                quality=quality,
                optimize=True,
                progressive=True
            )
            return True, jpeg_path
    except Exception as e:
        print(f"✗ Error compressing {image_path}: {str(e)}")
        return False, None

def backup_image(image_path, backup_dir):
    """
    Create a backup of an image file in the backup directory
    """
    try:
        backup_dir.mkdir(parents=True, exist_ok=True)
        backup_path = backup_dir / image_path.name
        shutil.copy2(image_path, backup_path)
        return True
    except Exception as e:
        print(f"  ✗ Failed to create backup: {str(e)}")
        return False

def compress_image(image_path, output_path=None, quality=85, max_dimension=2048, backup_dir=None, min_size_mb=1.0):
    """
    Compress a single image file
    """
    image_path = Path(image_path)
    
    if not image_path.exists():
        print(f"✗ File not found: {image_path}")
        return False
    
    # Get original size
    original_size_kb = get_file_size_kb(image_path)
    original_size_mb = get_file_size_mb(image_path)
    
    # Skip if file is smaller than minimum size
    if original_size_mb < min_size_mb:
        if original_size_mb >= 1:
            size_str = f"{original_size_mb:.2f}MB"
        else:
            size_str = f"{original_size_kb:.1f}KB"
        print(f"⊘ {image_path.name} ({size_str}) - Skipped (smaller than {min_size_mb}MB)")
        return False
    
    # Determine output path
    if output_path is None:
        output_path = image_path
    else:
        output_path = Path(output_path)
    
    # Compress based on file type
    ext = image_path.suffix.lower()
    success = False
    final_output_path = output_path
    
    if ext in ['.jpg', '.jpeg']:
        success = compress_jpeg(image_path, output_path, quality=quality, max_dimension=max_dimension)
    elif ext == '.png':
        success, final_output_path = compress_png(image_path, output_path, quality=quality, max_dimension=max_dimension)
        # If PNG was converted to JPG, we need to handle the file rename
        if success and final_output_path != output_path:
            # The PNG was converted to JPG, so we'll replace the original PNG
            pass
    else:
        print(f"✗ Unsupported file type: {ext}")
        return False
    
    if success:
        # Handle PNG to JPG conversion - delete original PNG if converted
        actual_output_path = image_path
        if final_output_path != output_path and final_output_path != image_path:
            # PNG was converted to JPG
            if image_path.suffix.lower() == '.png' and final_output_path.suffix.lower() == '.jpg':
                # Delete original PNG
                if image_path.exists():
                    image_path.unlink()
                # The JPG file is already saved at final_output_path
                actual_output_path = final_output_path
        else:
            # File was compressed in place
            actual_output_path = output_path
        
        # Get compressed size from the actual output file
        if not actual_output_path.exists():
            print(f"  ✗ Compressed file not found at {actual_output_path}")
            return False
        
        compressed_size_kb = get_file_size_kb(actual_output_path)
        compressed_size_mb = get_file_size_mb(actual_output_path)
        
        # Calculate savings
        reduction = ((original_size_kb - compressed_size_kb) / original_size_kb) * 100
        
        # Format sizes for display
        if original_size_mb >= 1:
            size_str = f"{original_size_mb:.2f}MB"
        else:
            size_str = f"{original_size_kb:.1f}KB"
        
        if compressed_size_mb >= 1:
            compressed_str = f"{compressed_size_mb:.2f}MB"
        else:
            compressed_str = f"{compressed_size_kb:.1f}KB"
        
        # Show the final filename
        print(f"✓ {actual_output_path.name}")
        print(f"  {size_str} → {compressed_str} ({reduction:.1f}% reduction)")
        
        return True
    
    return False

def compress_images_in_directory(directory_path, quality=85, max_dimension=2048, create_backup=True, min_size_mb=1.0):
    """
    Compress all images in a directory that are larger than min_size_mb
    """
    directory = Path(directory_path)
    if not directory.exists():
        print(f"Directory not found: {directory_path}")
        return
    
    # Supported image extensions
    image_extensions = {'.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG'}
    
    # Get all image files
    all_image_files = [f for f in directory.iterdir() 
                      if f.suffix in image_extensions and f.is_file()]
    
    if not all_image_files:
        print("No image files found in directory")
        return
    
    # Filter images by size (only those >= min_size_mb)
    image_files = [f for f in all_image_files if get_file_size_mb(f) >= min_size_mb]
    skipped_count = len(all_image_files) - len(image_files)
    
    if not image_files:
        print(f"No images found larger than {min_size_mb}MB")
        if skipped_count > 0:
            print(f"Skipped {skipped_count} image(s) smaller than {min_size_mb}MB")
        return
    
    # Create backup directory if backups are requested
    backup_dir = None
    if create_backup:
        backup_dir = directory / 'backups'
        print(f"Creating backups in: {backup_dir}")
        print("-" * 70)
        
        # Create backups for all images that will be compressed
        backup_count = 0
        for image_file in image_files:
            if backup_image(image_file, backup_dir):
                backup_count += 1
        
        print(f"✓ Created backups for {backup_count}/{len(image_files)} images")
        print("-" * 70)
        print()
    
    print(f"Found {len(all_image_files)} total image(s)")
    print(f"Compressing {len(image_files)} image(s) larger than {min_size_mb}MB")
    if skipped_count > 0:
        print(f"Skipping {skipped_count} image(s) smaller than {min_size_mb}MB")
    print(f"Quality: {quality}, Max dimension: {max_dimension}px")
    print("-" * 70)
    
    total_original = 0
    total_compressed = 0
    success_count = 0
    
    for image_file in image_files:
        original_size = get_file_size_kb(image_file)
        total_original += original_size
        
        if compress_image(image_file, quality=quality, max_dimension=max_dimension, backup_dir=backup_dir, min_size_mb=min_size_mb):
            # Determine the actual compressed file path
            # PNG might have been converted to JPG
            if image_file.exists():
                compressed_size = get_file_size_kb(image_file)
            else:
                # Check if PNG was converted to JPG
                jpg_path = image_file.with_suffix('.jpg')
                if jpg_path.exists():
                    compressed_size = get_file_size_kb(jpg_path)
                else:
                    # Fallback: use original size if we can't find compressed file
                    compressed_size = original_size
            total_compressed += compressed_size
            success_count += 1
        print()
    
    print("-" * 70)
    total_reduction = ((total_original - total_compressed) / total_original) * 100 if total_original > 0 else 0
    
    print(f"Compression complete: {success_count}/{len(image_files)} images compressed")
    print(f"Total size: {total_original/1024:.2f}MB → {total_compressed/1024:.2f}MB")
    print(f"Total reduction: {total_reduction:.1f}%")
    
    if create_backup and backup_dir:
        print(f"\n✓ Backups saved in: {backup_dir}")
        print("You can delete the backup directory after verifying the compressed images")

if __name__ == "__main__":
    # Get the directory of this script
    script_dir = Path(__file__).parent
    assets_dir = script_dir / "attached_assets"
    
    print("=" * 70)
    print("Image Compression Tool")
    print("=" * 70)
    print(f"Compressing images in: {assets_dir}")
    print()
    
    # Compression settings
    # quality: 85 is a good balance (0-100, higher = better quality but larger file)
    # max_dimension: 2048px should be enough for web, adjust if needed
    # min_size_mb: Only compress images larger than this size (default: 1.0 MB)
    compress_images_in_directory(
        assets_dir,
        quality=85,
        max_dimension=2048,
        create_backup=True,
        min_size_mb=1.0
    )
    print()
    print("Done!")

