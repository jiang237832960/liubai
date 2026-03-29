# 秒启专注 - 技术规格文档

## 1. 项目概述

### 1.1 产品定位
纯单机离线运行的极简专注计时工具，主打「打开即计时、免费手动补录时长、支持本地白噪音导入、一次性永久买断无订阅」。

### 1.2 核心原则
- **零服务器成本**：所有功能本地闭环，无需后端服务
- **纯单机运行**：全程离线可用，无网络依赖
- **无社交干扰**：无排行榜、自习室、社区等功能
- **一次性买断**：拒绝订阅制，永久解锁

---

## 2. 技术架构

### 2.1 技术栈选型

| 技术模块 | 选型方案 | 版本要求 | 选型理由 |
|---------|---------|---------|---------|
| 跨平台框架 | Flutter | >=3.16.0 | 一套代码适配iOS+Android，性能接近原生 |
| 编程语言 | Dart | >=3.0.0 | Flutter官方语言，类型安全 |
| 本地数据库 | sqflite | ^2.3.0 | SQLite封装，轻量可靠 |
| 状态管理 | Riverpod | ^2.4.0 | 类型安全、可测试、性能优秀 |
| 本地存储 | shared_preferences | ^2.2.0 | 简单键值存储，适合配置项 |
| 音频播放 | just_audio | ^0.9.35 | 功能完善，支持本地文件 |
| 文件选择 | file_picker | ^6.1.0 | 跨平台文件选择器 |
| 权限管理 | permission_handler | ^11.0.0 | 统一权限申请接口 |
| 内购实现 | in_app_purchase | ^3.1.0 | 官方SDK封装，合规安全 |
| 数据导出 | share_plus | ^7.2.0 | 系统分享功能 |
| 路径管理 | path_provider | ^2.1.0 | 跨平台路径获取 |

### 2.2 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
├── core/                        # 核心基础设施
│   ├── constants/               # 常量定义
│   │   ├── app_constants.dart   # 应用常量
│   │   ├── database_constants.dart  # 数据库常量
│   │   └── storage_keys.dart    # 存储键名
│   ├── theme/                   # 主题配置
│   │   ├── app_theme.dart       # 主题定义
│   │   ├── app_colors.dart      # 颜色配置
│   │   └── app_text_styles.dart # 文字样式
│   ├── utils/                   # 工具函数
│   │   ├── date_time_utils.dart # 时间工具
│   │   ├── duration_utils.dart  # 时长工具
│   │   └── validators.dart      # 验证器
│   └── extensions/              # 扩展方法
│       ├── date_time_extension.dart
│       └── duration_extension.dart
├── data/                        # 数据层
│   ├── database/                # 数据库
│   │   ├── database_helper.dart # 数据库助手
│   │   ├── database_schema.dart # 数据库结构
│   │   └── migrations/          # 数据库迁移
│   ├── models/                  # 数据模型
│   │   ├── focus_session.dart   # 专注会话
│   │   ├── focus_session.g.dart # 生成的代码
│   │   ├── interruption.dart    # 中断记录
│   │   ├── interruption.g.dart
│   │   ├── daily_summary.dart   # 每日汇总
│   │   ├── daily_summary.g.dart
│   │   ├── scene_tag.dart       # 场景标签
│   │   ├── scene_tag.g.dart
│   │   ├── user_settings.dart   # 用户设置
│   │   └── user_settings.g.dart
│   ├── repositories/            # 数据仓库
│   │   ├── focus_repository.dart
│   │   ├── summary_repository.dart
│   │   ├── settings_repository.dart
│   │   └── purchase_repository.dart
│   └── datasources/             # 数据源
│       ├── local_data_source.dart
│       └── purchase_data_source.dart
├── domain/                      # 领域层
│   ├── entities/                # 领域实体
│   ├── usecases/                # 用例
│   └── repositories/            # 仓库接口
├── presentation/                # 表现层
│   ├── providers/               # 状态提供者
│   │   ├── timer_provider.dart
│   │   ├── session_provider.dart
│   │   ├── summary_provider.dart
│   │   ├── settings_provider.dart
│   │   └── purchase_provider.dart
│   ├── pages/                   # 页面
│   │   ├── home/                # 首页（计时页）
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   ├── history/             # 历史记录
│   │   │   ├── history_page.dart
│   │   │   └── widgets/
│   │   ├── summary/             # 数据复盘
│   │   │   ├── summary_page.dart
│   │   │   └── widgets/
│   │   ├── settings/            # 设置
│   │   │   ├── settings_page.dart
│   │   │   └── widgets/
│   │   ├── manual_entry/        # 手动补录
│   │   │   └── manual_entry_page.dart
│   │   └── purchase/            # 购买页面
│   │       └── purchase_page.dart
│   └── widgets/                 # 公共组件
│       ├── common/              # 通用组件
│       ├── timer/               # 计时相关
│       └── charts/              # 图表组件
├── services/                    # 服务层
│   ├── audio_service.dart       # 音频服务
│   ├── notification_service.dart # 通知服务
│   ├── purchase_service.dart    # 内购服务
│   └── export_service.dart      # 导出服务
└── features/                    # 功能模块（按版本划分）
    ├── v1_0_mvp/                # V1.0 MVP功能
    ├── v1_1_enhanced/           # V1.1 增强功能
    ├── v1_2_premium/            # V1.2 高级功能
    └── v1_3_optimization/       # V1.3 优化功能
```

---

## 3. 数据库设计

### 3.1 数据库Schema

```sql
-- 专注会话表
CREATE TABLE focus_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    start_time INTEGER NOT NULL,           -- 开始时间戳（毫秒）
    end_time INTEGER,                       -- 结束时间戳（毫秒）
    planned_duration INTEGER NOT NULL,      -- 计划时长（分钟）
    actual_duration INTEGER,                -- 实际时长（分钟）
    is_completed INTEGER DEFAULT 0,         -- 是否完成（0/1）
    is_manual_entry INTEGER DEFAULT 0,      -- 是否手动补录（0/1）
    scene_tag_id INTEGER,                   -- 场景标签ID
    note TEXT,                              -- 备注
    created_at INTEGER NOT NULL,            -- 创建时间
    updated_at INTEGER NOT NULL             -- 更新时间
);

-- 中断记录表
CREATE TABLE interruptions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,            -- 关联的专注会话ID
    interrupt_time INTEGER NOT NULL,        -- 中断时间戳
    resume_time INTEGER,                    -- 恢复时间戳
    reason TEXT,                            -- 中断原因
    created_at INTEGER NOT NULL,
    FOREIGN KEY (session_id) REFERENCES focus_sessions(id) ON DELETE CASCADE
);

-- 场景标签表
CREATE TABLE scene_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                     -- 标签名称
    color INTEGER,                          -- 标签颜色
    sort_order INTEGER DEFAULT 0,           -- 排序
    is_default INTEGER DEFAULT 0,           -- 是否默认标签
    created_at INTEGER NOT NULL
);

-- 每日汇总表（自动生成）
CREATE TABLE daily_summaries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL UNIQUE,              -- 日期（YYYY-MM-DD）
    total_duration INTEGER DEFAULT 0,       -- 总专注时长（分钟）
    session_count INTEGER DEFAULT 0,        -- 会话次数
    interruption_count INTEGER DEFAULT 0,   -- 中断次数
    completed_count INTEGER DEFAULT 0,      -- 完成次数
    scene_distribution TEXT,                -- 场景分布（JSON）
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- 用户设置表
CREATE TABLE user_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),  -- 单条记录
    default_duration INTEGER DEFAULT 25,    -- 默认专注时长
    enable_sound INTEGER DEFAULT 1,         -- 是否启用声音
    enable_notification INTEGER DEFAULT 1,  -- 是否启用通知
    theme_mode TEXT DEFAULT 'system',       -- 主题模式
    is_premium INTEGER DEFAULT 0,           -- 是否高级用户
    purchase_date INTEGER,                  -- 购买时间
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- 白噪音配置表
CREATE TABLE white_noise_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                     -- 名称
    file_path TEXT,                         -- 文件路径（本地导入）
    is_builtin INTEGER DEFAULT 0,           -- 是否内置
    volume REAL DEFAULT 1.0,                -- 音量（0-1）
    is_active INTEGER DEFAULT 0,            -- 是否当前启用
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
);
```

### 3.2 数据模型类

```dart
// focus_session.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_session.freezed.dart';
part 'focus_session.g.dart';

@freezed
class FocusSession with _$FocusSession {
  const factory FocusSession({
    int? id,
    required DateTime startTime,
    DateTime? endTime,
    required int plannedDuration,
    int? actualDuration,
    @Default(false) bool isCompleted,
    @Default(false) bool isManualEntry,
    int? sceneTagId,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FocusSession;

  factory FocusSession.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionFromJson(json);
}
```

---

## 4. 核心功能规格

### 4.1 V1.0 MVP 核心功能

#### 4.1.1 秒启计时
- **启动时间**：App冷启动到计时页面 < 1秒
- **默认时长**：25分钟（可配置）
- **计时精度**：秒级
- **后台运行**：支持后台计时，显示持久通知
- **中断处理**：
  - 自动记录中断时间点
  - 支持标注中断原因
  - 恢复后继续计时

#### 4.1.2 每日极简复盘
- **自动统计**：每日0点自动生成前日数据
- **核心指标**：
  - 总专注时长
  - 专注次数
  - 中断次数
  - 完成率
- **展示形式**：简洁卡片式，无图表

### 4.2 V1.1 差异化功能

#### 4.2.1 手动补录
- **补录范围**：支持补录过去30天内数据
- **字段**：日期、时长、场景标签、备注
- **限制**：单次最长4小时，单日累计不超过16小时

#### 4.2.2 数据导出
- **格式**：JSON / CSV
- **范围**：可选时间范围导出
- **方式**：系统分享面板

#### 4.2.3 本地白噪音
- **内置**：3款无版权白噪音（雨声、咖啡厅、森林）
- **导入**：支持用户导入本地音频文件
- **格式支持**：MP3, WAV, M4A, AAC
- **播放控制**：播放/暂停、音量调节

### 4.3 V1.2 高级功能（一次性买断解锁）

#### 4.3.1 深度复盘
- **时间维度**：周/月/年视图
- **趋势分析**：专注时长趋势图
- **中断分析**：中断原因汇总统计
- **场景分析**：各场景专注时长分布

#### 4.3.2 个性化定制
- **主题**：多套极简主题
- **页面元素**：可自定义显示/隐藏
- **白噪音高级**：多音频混合、场景预设

#### 4.3.3 多设备同步
- **iOS**：iCloud同步
- **Android**：Google Drive / 厂商云服务
- **本地WiFi**：点对点数据互传

---

## 5. UI/UX 设计规范

### 5.1 设计原则
- **极简主义**：每页核心功能不超过3个
- **秒级响应**：所有操作响应时间 < 100ms
- **无障碍**：支持字体缩放、屏幕阅读器

### 5.2 页面结构

```
首页（计时页）
├── 顶部：当前时间/日期
├── 中部：大字体计时器（核心视觉）
├── 底部：开始/暂停按钮 + 设置入口
└── 底部导航：计时 | 历史 | 复盘 | 设置

历史页
├── 列表：按日期倒序排列
├── 单条：时间、时长、标签、完成状态
└── 操作：编辑、删除、筛选

复盘页（V1.0免费版）
└── 今日数据卡片：总时长、次数、中断

复盘页（高级版解锁后）
├── 周/月/年切换
├── 趋势图表
├── 场景分布
└── 中断分析

设置页
├── 计时设置：默认时长、声音、通知
├── 数据管理：导出、导入、清除
├── 高级功能：购买入口（未购买）/ 功能列表（已购买）
└── 关于：版本、反馈、隐私政策
```

### 5.3 颜色系统

```dart
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF2D3142);
  static const Color primaryLight = Color(0xFF4F5569);
  static const Color accent = Color(0xFFEF8354);
  
  // 背景色
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9ECEF);
  
  // 文字色
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212529);
  static const Color onSurface = Color(0xFF495057);
  static const Color onSurfaceVariant = Color(0xFF6C757D);
  
  // 功能色
  static const Color success = Color(0xFF52B788);
  static const Color warning = Color(0xFFFFB703);
  static const Color error = Color(0xFFE63946);
}
```

---

## 6. 性能指标

### 6.1 启动性能
- 冷启动时间：< 1秒
- 热启动时间：< 300ms

### 6.2 运行性能
- 计时精度误差：< 1秒/小时
- 内存占用：< 100MB
- 后台CPU占用：< 1%

### 6.3 数据库性能
- 查询响应：< 50ms（10万条数据）
- 写入响应：< 20ms

---

## 7. 安全与合规

### 7.1 数据安全
- 所有数据本地存储，不上传服务器
- 数据库文件加密（SQLCipher）
- 导出文件不包含敏感信息

### 7.2 权限申请
| 权限 | 用途 | 是否必须 |
|-----|------|---------|
| 存储权限 | 导入白噪音、导出数据 | 否（使用时申请）|
| 通知权限 | 后台计时提醒 | 否（可选）|
| 音频权限 | 播放白噪音 | 否（可选）|

### 7.3 合规要求
- 符合《个人信息保护法》
- 应用商店审核规范
- 内购合规：明确标注权益，无隐藏消费

---

## 8. 测试策略

### 8.1 单元测试
- 数据模型序列化/反序列化
- 工具函数
- 状态管理逻辑

### 8.2 集成测试
- 数据库CRUD操作
- 计时器逻辑
- 内购流程

### 8.3 手动测试清单
- [ ] 跨天计时是否正确
- [ ] 后台杀进程恢复
- [ ] 低电量模式表现
- [ ] 不同屏幕尺寸适配
- [ ] 深色模式切换

---

## 9. 发布 checklist

### 9.1 应用商店准备
- [ ] 应用图标（各尺寸）
- [ ] 截图（iPhone/iPad/安卓各尺寸）
- [ ] 应用描述文案
- [ ] 隐私政策页面
- [ ] 内购商品配置

### 9.2 技术准备
- [ ] 版本号更新
- [ ] 混淆配置
- [ ] 签名配置
- [ ] 测试账号准备

---

## 10. 版本迭代计划

| 版本 | 周期 | 核心交付物 | 里程碑 |
|-----|------|-----------|--------|
| V1.0 | 7天 | 秒启计时、每日复盘 | 上线验证 |
| V1.1 | 4天 | 手动补录、数据导出、白噪音 | 差异化强化 |
| V1.2 | 4天 | 内购、高级功能 | 变现闭环 |
| V1.3 | 持续 | 优化迭代 | 用户留存 |

---

## 附录

### A. 依赖清单

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.2.0
  
  # 数据库
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # 本地存储
  shared_preferences: ^2.2.0
  
  # 音频
  just_audio: ^0.9.35
  audio_session: ^0.1.18
  
  # 文件
  file_picker: ^6.1.0
  path_provider: ^2.1.0
  share_plus: ^7.2.0
  
  # 权限
  permission_handler: ^11.0.0
  
  # 内购
  in_app_purchase: ^3.1.0
  
  # 通知
  flutter_local_notifications: ^16.0.0
  
  # 工具
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  intl: ^0.18.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0
```

### B. 命名规范

- **文件命名**：小写下划线（snake_case）
- **类命名**：大驼峰（PascalCase）
- **变量/函数**：小驼峰（camelCase）
- **常量**：大写下划线（SCREAMING_SNAKE_CASE）
