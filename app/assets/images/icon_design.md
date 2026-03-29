# 留白 App 图标设计规范

## 设计理念

### 核心概念
以"留白"的东方美学为核心，用最简洁的设计语言表达品牌的极简、禅意、东方特质。

### 设计元素
- **主元素**："留"字或"白"字的极简演绎
- **辅助元素**：四个点代表留白的四个角
- **背景**：纯净的白色或淡墨色

## 图标方案

### 方案一：文字图标（推荐）

#### 设计说明
使用"留"字或"白"字作为图标主体，采用极简的无衬线字体，营造东方美学的留白意境。

#### 视觉规范
- **字体**：思源黑体 Light
- **颜色**：墨黑 (#1A1A1A)
- **背景**：纯白 (#FFFFFF)
- **构图**：文字居中，四周大量留白

#### 尺寸规范
| 尺寸 | 用途 | 文件命名 |
|------|------|----------|
| 1024x1024 | App Store | icon_1024x1024.png |
| 512x512 | 应用商店 | icon_512x512.png |
| 192x192 | Android xxxhdpi | ic_launcher.png |
| 144x144 | Android xxhdpi | ic_launcher.png |
| 96x96 | Android xhdpi | ic_launcher.png |
| 72x72 | Android hdpi | ic_launcher.png |
| 48x48 | Android mdpi | ic_launcher.png |
| 180x180 | iOS @3x | Icon-60@3x.png |
| 120x120 | iOS @2x | Icon-60@2x.png |
| 1024x1024 | iOS App Store | iTunesArtwork@2x.png |

### 方案二：几何图标

#### 设计说明
使用四个点代表留白的四个角，中间留白，形成极简的几何图形。

#### 视觉规范
- **元素**：四个圆点
- **颜色**：墨黑 (#1A1A1A)
- **背景**：纯白 (#FFFFFF)
- **构图**：四个点分别位于四角，中间大量留白

#### 布局
```
    ●           ●
    
    
    
    ●           ●
```

## 启动图设计

### 设计规范
- **背景色**：留白白 (#FFFFFF)
- **主元素**："留 白" 品牌名
- **字体**：思源黑体 Light
- **字号**：48pt
- **字间距**：16pt
- **颜色**：墨黑 (#1A1A1A)

### 布局
```
┌─────────────────────────────┐
│                             │
│                             │
│                             │
│                             │
│        留 白                │
│                             │
│                             │
│                             │
│                             │
└─────────────────────────────┘
```

### 尺寸规范
| 尺寸 | 用途 | 文件命名 |
|------|------|----------|
| 1242x2688 | iPhone Xs Max | LaunchImage-1242x2688.png |
| 828x1792 | iPhone Xr | LaunchImage-828x1792.png |
| 1125x2436 | iPhone X/Xs | LaunchImage-1125x2436.png |
| 750x1334 | iPhone 8/7/6s/6 | LaunchImage-750x1334.png |
| 640x1136 | iPhone SE/5s/5 | LaunchImage-640x1136.png |
| 2048x2732 | iPad Pro 12.9" | LaunchImage-2048x2732.png |
| 1668x2224 | iPad Pro 10.5" | LaunchImage-1668x2224.png |
| 1536x2048 | iPad Air/Mini | LaunchImage-1536x2048.png |

## 适配深色模式

### 深色模式图标
- **背景**：墨黑 (#1A1A1A)
- **文字/图形**：纯白 (#FFFFFF)

### 深色模式启动图
- **背景**：墨黑 (#1A1A1A)
- **品牌名**：纯白 (#FFFFFF)

## 文件结构

```
assets/
└── images/
    ├── icon_design.md          # 设计规范文档
    ├── icon.png                # 主图标（1024x1024）
    ├── icon_dark.png           # 深色模式图标
    └── launch/
        ├── launch_image.png    # 启动图（1242x2688）
        └── launch_image_dark.png # 深色模式启动图

android/app/src/main/res/
├── mipmap-mdpi/
│   └── ic_launcher.png       # 48x48
├── mipmap-hdpi/
│   └── ic_launcher.png       # 72x72
├── mipmap-xhdpi/
│   └── ic_launcher.png       # 96x96
├── mipmap-xxhdpi/
│   └── ic_launcher.png       # 144x144
└── mipmap-xxxhdpi/
    └── ic_launcher.png       # 192x192

ios/Runner/Assets.xcassets/
├── AppIcon.appiconset/
│   ├── Contents.json
│   ├── Icon-20x20@1x.png
│   ├── Icon-20x20@2x.png
│   ├── Icon-20x20@3x.png
│   ├── Icon-29x29@1x.png
│   ├── Icon-29x29@2x.png
│   ├── Icon-29x29@3x.png
│   ├── Icon-40x40@1x.png
│   ├── Icon-40x40@2x.png
│   ├── Icon-40x40@3x.png
│   ├── Icon-60x60@2x.png
│   ├── Icon-60x60@3x.png
│   ├── Icon-76x76@1x.png
│   ├── Icon-76x76@2x.png
│   ├── Icon-83.5x83.5@2x.png
│   └── iTunesArtwork@2x.png
└── LaunchImage.imageset/
    ├── Contents.json
    ├── LaunchImage.png
    ├── LaunchImage@2x.png
    └── LaunchImage@3x.png
```

## 生成工具推荐

### 图标生成
- [App Icon Generator](https://appicon.co/)
- [Icon Kitchen](https://icon.kitchen/)
- [Figma](https://figma.com) - 设计工具

### 启动图生成
- [Launch Screen Generator](https://launchscreen.studio/)
- [Ape Tools](http://apetools.webprofusion.com/)

## 注意事项

1. **保持简洁**：图标和启动图都要保持极简风格
2. **品牌一致性**：所有视觉元素都要符合"留白"的品牌调性
3. **可读性**：确保在小尺寸下依然清晰可辨
4. **适配性**：确保在不同设备和模式下都能正常显示
5. **版权**：使用开源字体和素材，避免版权纠纷
