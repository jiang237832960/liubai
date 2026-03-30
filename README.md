# 留白

东方美学极简专注工具

## 品牌理念

留白，是中国画的最高境界。

不是「没有」，而是「无限」。
于空白处，见天地，见自己。

专注，亦是如此。
不是填满每一分钟，
而是给心灵留白，
让思绪在空白处自由生长。

## 产品特色

### 极简设计
- 大量留白，回归专注本质
- 东方美学，现代演绎
- 墨黑与留白，简约而不简单

### 场景模板
- 自定义专注场景
- 支持多轮番茄钟
- 工作与休息自由搭配

### 留白音
- 精选环境音效
- 雨声、海浪、森林、咖啡厅
- 沉浸式专注体验

### 数据洞察
- 留白时长统计
- 场景分布分析
- 专注趋势追踪

## 开始使用

### 环境要求
- Flutter SDK 3.x
- Dart 3.x

### 安装依赖

```bash
cd app
flutter pub get
```

### 运行应用

```bash
# debug 模式
flutter run

# release 模式
flutter build apk --release
```

详细构建指南请参考 [LOCAL_BUILD_GUIDE.md](app/LOCAL_BUILD_GUIDE.md)

## 项目结构

```
app/
├── lib/
│   ├── core/                 # 核心模块
│   │   ├── theme.dart        # 品牌主题配置
│   │   ├── utils.dart        # 工具函数
│   │   └── logger.dart       # 日志服务
│   ├── data/                 # 数据层
│   │   ├── database.dart     # SQLite 数据库
│   │   └── models/           # 数据模型
│   ├── services/             # 业务服务
│   │   ├── timeline_engine.dart     # 计时引擎
│   │   ├── template_service.dart    # 场景模板服务
│   │   └── audio_service.dart       # 音频服务
│   ├── providers/             # 状态管理
│   └── presentation/         # UI 层
│       ├── home_page.dart           # 首页
│       ├── log_page.dart            # 留白日志
│       ├── stats_page.dart          # 留白统计
│       └── settings_page.dart       # 设置
├── assets/
│   └── audio/                # 环境音效资源
└── pubspec.yaml
```

## 设计规范

详见 `design/` 目录：

- [品牌完整方案](design/brand_liubai.md) - 品牌定位、视觉识别系统
- [UI设计规范](design/ui_design_spec.md) - 页面布局、交互细节

## 技术栈

- **框架**: Flutter
- **状态管理**: Riverpod
- **本地存储**: SQLite (sqflite)
- **音频播放**: audioplayers

## License

MIT License
