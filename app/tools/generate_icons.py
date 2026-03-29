#!/usr/bin/env python3
"""
留白 App 图标生成脚本
使用 Pillow 库生成各种尺寸的图标
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def create_icon(size, is_dark=False, text="留"):
    """创建单个图标"""
    # 颜色定义
    bg_color = "#1A1A1A" if is_dark else "#FFFFFF"
    text_color = "#FFFFFF" if is_dark else "#1A1A1A"
    
    # 创建图像
    img = Image.new('RGB', (size, size), bg_color)
    draw = ImageDraw.Draw(img)
    
    # 尝试加载中文字体
    font = None
    font_size = int(size * 0.5)
    
    # 尝试不同的字体路径
    font_paths = [
        # Windows
        "C:/Windows/Fonts/simhei.ttf",  # 黑体
        "C:/Windows/Fonts/simsun.ttc",  # 宋体
        "C:/Windows/Fonts/msyh.ttc",    # 微软雅黑
        "C:/Windows/Fonts/msgothic.ttc", # 日文 Gothic（备用）
        # macOS
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/Library/Fonts/Arial Unicode.ttf",
        # Linux
        "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
        "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
    ]
    
    for font_path in font_paths:
        try:
            if os.path.exists(font_path):
                font = ImageFont.truetype(font_path, font_size)
                print(f"  使用字体: {font_path}")
                break
        except Exception as e:
            continue
    
    if font is None:
        print("  警告: 未找到中文字体，使用默认字体")
        font = ImageFont.load_default()
    
    # 计算文字位置使其居中
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) / 2 - bbox[0]
    y = (size - text_height) / 2 - bbox[1]
    
    # 绘制文字
    draw.text((x, y), text, fill=text_color, font=font)
    
    return img

def create_geometric_icon(size, is_dark=False):
    """创建几何图标（四个点）"""
    bg_color = "#1A1A1A" if is_dark else "#FFFFFF"
    dot_color = "#FFFFFF" if is_dark else "#1A1A1A"
    
    img = Image.new('RGB', (size, size), bg_color)
    draw = ImageDraw.Draw(img)
    
    # 点的位置和大小
    padding = int(size * 0.25)
    dot_radius = int(size * 0.06)
    
    # 四个角的位置
    positions = [
        (padding, padding),  # 左上
        (size - padding, padding),  # 右上
        (padding, size - padding),  # 左下
        (size - padding, size - padding),  # 右下
    ]
    
    for x, y in positions:
        draw.ellipse(
            [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
            fill=dot_color
        )
    
    return img

def save_icon(img, path):
    """保存图标"""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, 'PNG')
    print(f"  ✓ {path}")

def main():
    print("🎨 留白 App 图标生成工具")
    print("=" * 50)
    
    # 检查 Pillow
    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("❌ 错误: 需要安装 Pillow 库")
        print("   运行: pip install Pillow")
        sys.exit(1)
    
    # 创建输出目录
    base_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(base_dir, '..', 'generated_icons')
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"\n📁 输出目录: {output_dir}")
    print()
    
    # 方案一：文字图标
    print("方案一：文字图标（推荐）")
    print("-" * 50)
    
    # 主图标
    print("生成主图标 (1024x1024)...")
    icon = create_icon(1024, is_dark=False, text="留")
    save_icon(icon, os.path.join(output_dir, 'icon_1024x1024.png'))
    
    icon_dark = create_icon(1024, is_dark=True, text="留")
    save_icon(icon_dark, os.path.join(output_dir, 'icon_dark_1024x1024.png'))
    
    # Android 图标
    print("\n生成 Android 图标...")
    android_sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    
    for name, size in android_sizes.items():
        icon = create_icon(size, is_dark=False, text="留")
        save_icon(icon, os.path.join(output_dir, 'android', f'ic_launcher_{name}.png'))
    
    # iOS 图标
    print("\n生成 iOS 图标...")
    ios_sizes = {
        'Icon-20x20@1x': 20,
        'Icon-20x20@2x': 40,
        'Icon-20x20@3x': 60,
        'Icon-29x29@1x': 29,
        'Icon-29x29@2x': 58,
        'Icon-29x29@3x': 87,
        'Icon-40x40@1x': 40,
        'Icon-40x40@2x': 80,
        'Icon-40x40@3x': 120,
        'Icon-60x60@2x': 120,
        'Icon-60x60@3x': 180,
        'Icon-76x76@1x': 76,
        'Icon-76x76@2x': 152,
        'Icon-83.5x83.5@2x': 167,
        'iTunesArtwork@2x': 1024,
    }
    
    for name, size in ios_sizes.items():
        icon = create_icon(size, is_dark=False, text="留")
        save_icon(icon, os.path.join(output_dir, 'ios', f'{name}.png'))
    
    # 方案二：几何图标
    print("\n" + "=" * 50)
    print("方案二：几何图标")
    print("-" * 50)
    
    print("生成几何图标...")
    icon_geo = create_geometric_icon(1024, is_dark=False)
    save_icon(icon_geo, os.path.join(output_dir, 'icon_geometric_1024x1024.png'))
    
    icon_geo_dark = create_geometric_icon(1024, is_dark=True)
    save_icon(icon_geo_dark, os.path.join(output_dir, 'icon_geometric_dark_1024x1024.png'))
    
    print("\n" + "=" * 50)
    print("✅ 图标生成完成！")
    print()
    print("下一步:")
    print("1. 检查 generated_icons/ 目录中的图标")
    print("2. 将 Android 图标复制到 android/app/src/main/res/mipmap-xxx/")
    print("3. 将 iOS 图标复制到 ios/Runner/Assets.xcassets/AppIcon.appiconset/")
    print()

if __name__ == '__main__':
    main()
