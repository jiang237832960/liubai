# 秒启专注 - UI交互设计规范

## 📋 设计理念

### 核心原则
基于番茄Todo和专注森林的优势，结合「秒启专注」的极简定位，打造：
- **秒级响应**：打开即计时，零等待
- **视觉清晰**：大字体计时器，一目了然
- **反馈及时**：每个操作都有明确反馈
- **无干扰**：去除所有非核心元素

### 竞品优势提取

| 产品 | 优势 | 秒启专注借鉴 |
|-----|------|------------|
| **番茄Todo** | 清晰的番茄钟界面 | ✅ 大字体计时器 |
| **番茄Todo** | 简洁卡片式设计 | ✅ 卡片式数据展示 |
| **番茄Todo** | 丰富的数据统计 | ✅ 极简数据卡片 |
| **番茄Todo** | 白噪音功能 | ✅ 本地白噪音 |
| **专注森林** | 强烈的视觉反馈 | ✅ 进度环/条动画 |
| **专注森林** | 简洁可爱风格 | ✅ 温和的色彩系统 |
| **专注森林** | 沉浸式体验 | ✅ 沉浸式计时模式 |

---

## 🎨 视觉系统

### 1. 色彩系统

#### 主色调（借鉴番茄Todo的清晰配色）
```dart
class AppColors {
  // 主色 - 深蓝灰（专注感）
  static const Color primary = Color(0xFF2D3142);
  static const Color primaryDark = Color(0xFF1F2230);
  static const Color primaryLight = Color(0xFF4F5569);
  
  // 强调色 - 橙红色（活力感，借鉴专注森林）
  static const Color accent = Color(0xFFEF8354);
  static const Color accentLight = Color(0xFFF4A261);
  
  // 成功色 - 绿色（完成感）
  static const Color success = Color(0xFF52B788);
  
  // 背景色（极简风格）
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9ECEF);
  
  // 文字色
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF495057);
  static const Color textTertiary = Color(0xFF6C757D);
  
  // 深色模式
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
}
```

### 2. 字体系统

```dart
class AppTextStyles {
  // 计时器大字体（核心视觉）
  static const TextStyle timerDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w300,
    letterSpacing: -2,
    height: 1.0,
  );
  
  // 标题
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  // 正文
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  // 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
```

### 3. 间距系统

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### 4. 圆角系统

```dart
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}
```

---

## 📱 页面设计

### 首页（计时页）

#### 布局结构
```
┌─────────────────────────────┐
│  当前时间/日期（顶部）      │
├─────────────────────────────┤
│                             │
│      ┌───────────┐          │
│      │  25:00    │          │
│      │  计时器   │          │
│      └───────────┘          │
│                             │
│    进度环/进度条            │
│                             │
│   [开始] [暂停] [停止]       │
│                             │
├─────────────────────────────┤
│  计时 | 历史 | 复盘 | 设置  │
└─────────────────────────────┘
```

#### 设计要点
- **计时器**：超大字体（72pt），借鉴番茄Todo的清晰显示
- **进度环**：借鉴专注森林的视觉反馈，使用渐变色
- **按钮**：大尺寸（最小44pt），易于点击
- **背景**：极简纯色，无干扰元素

#### 交互细节
- **启动**：点击「开始」后，计时器立即开始倒计时
- **暂停**：点击「暂停」，进度环变为灰色，按钮变为「继续」
- **停止**：点击「停止」，弹出确认弹窗（借鉴番茄Todo）
- **完成**：倒计时结束，显示完成动画（借鉴专注森林的反馈）

#### 沉浸式模式
- 点击计时器进入沉浸式模式
- 隐藏底部导航和顶部信息
- 仅显示计时器和进度环
- 点击任意位置退出沉浸式模式

---

### 历史记录页

#### 布局结构
```
┌─────────────────────────────┐
│  历史记录          [筛选]   │
├─────────────────────────────┤
│  今天                      │
│  ┌─────────────────────┐   │
│  │ 10:00-10:25 25分钟 │   │
│  │ 学习  ✓ 完成        │   │
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ 14:00-14:30 30分钟 │   │
│  │ 工作  ✓ 完成        │   │
│  └─────────────────────┘   │
│                             │
│  昨天                      │
│  ┌─────────────────────┐   │
│  │ 09:00-09:25 25分钟 │   │
│  │ 学习  ✓ 完成        │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

#### 设计要点
- **卡片式设计**：借鉴番茄Todo的卡片风格
- **分组显示**：按日期分组，清晰易读
- **状态标识**：完成/未完成用不同颜色标识
- **滑动操作**：左滑删除，右滑编辑（借鉴番茄Todo）

#### 交互细节
- **点击卡片**：展开详情，显示中断记录
- **长按卡片**：显示操作菜单（编辑、删除、复制）
- **筛选**：点击筛选按钮，按场景/状态筛选

---

### 复盘页（V1.0免费版）

#### 布局结构
```
┌─────────────────────────────┐
│  今日复盘                  │
├─────────────────────────────┤
│  ┌─────────────────────┐   │
│  │   总专注时长        │   │
│  │     2小时30分      │   │
│  └─────────────────────┘   │
│                             │
│  ┌──────┐ ┌──────┐        │
│  │ 6次  │ │ 2次  │        │
│  │专注  │ │中断  │        │
│  └──────┘ └──────┘        │
│                             │
│  ┌─────────────────────┐   │
│  │   完成率  100%     │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

#### 设计要点
- **数据卡片**：借鉴番茄Todo的简洁卡片
- **大数字**：关键数据用大字体显示
- **极简布局**：仅显示核心指标

---

### 复盘页（V1.2高级版）

#### 布局结构
```
┌─────────────────────────────┐
│  周 | 月 | 年              │
├─────────────────────────────┤
│  趋势图表（折线图）        │
│  ┌─────────────────────┐   │
│  │     ╱╲╱╲          │   │
│  │    ╱  ╲  ╲         │   │
│  │   ╱    ╲   ╲        │   │
│  └─────────────────────┘   │
│                             │
│  场景分布（饼图）           │
│  ┌──────┐ ┌──────┐        │
│  │学习  │ │工作  │        │
│  │ 60%  │ │ 40%  │        │
│  └──────┘ └──────┘        │
│                             │
│  中断原因分析               │
│  ┌─────────────────────┐   │
│  │ 手机通知  3次       │   │
│  │ 休息      2次       │   │
│  │ 其他      1次       │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

#### 设计要点
- **图表**：使用 fl_chart 库，借鉴番茄Todo的图表风格
- **切换视图**：周/月/年切换，动画过渡
- **色彩区分**：不同场景用不同颜色

---

### 设置页

#### 布局结构
```
┌─────────────────────────────┐
│  设置                      │
├─────────────────────────────┤
│  计时设置                  │
│  ┌─────────────────────┐   │
│  │ 默认时长  25分钟 > │   │
│  │ 声音提醒  [开]     │   │
│  │ 通知提醒  [开]     │   │
│  └─────────────────────┘   │
│                             │
│  外观设置                  │
│  ┌─────────────────────┐   │
│  │ 主题模式  跟随系统>│   │
│  └─────────────────────┘   │
│                             │
│  数据管理                  │
│  ┌─────────────────────┐   │
│  │ 导出数据           │   │
│  │ 清除数据           │   │
│  └─────────────────────┘   │
│                             │
│  高级功能                  │
│  ┌─────────────────────┐   │
│  │ [🔒] 深度复盘     │   │
│  │ [🔒] 个性化定制     │   │
│  │ [🔒] 多设备同步     │   │
│  │ ───────────────    │   │
│  │ 解锁全部高级功能    │   │
│  │ 一次性买断 ¥18     │   │
│  └─────────────────────┘   │
│                             │
│  关于                      │
│  ┌─────────────────────┐   │
│  │ 版本 1.0.0         │   │
│  │ 反馈               │   │
│  │ 隐私政策           │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

#### 设计要点
- **分组清晰**：借鉴番茄Todo的分组设置
- **开关控件**：使用系统原生开关
- **锁定标识**：高级功能用🔒标识
- **购买引导**：清晰的购买入口

---

### 手动补录页（V1.1）

#### 布局结构
```
┌─────────────────────────────┐
│  手动补录          [取消]  │
├─────────────────────────────┤
│  日期                      │
│  ┌─────────────────────┐   │
│  │ 2026-03-07        >   │
│  └─────────────────────┘   │
│                             │
│  时长                      │
│  ┌─────────────────────┐   │
│  │  1  小时 30  分钟  │   │
│  └─────────────────────┘   │
│                             │
│  场景标签                  │
│  ┌────┐ ┌────┐ ┌────┐    │
│  │学习│ │工作│ │阅读│    │
│  └────┘ └────┘ └────┘    │
│  ┌────┐ ┌────┐           │
│  │运动│ │+添加│           │
│  └────┘ └────┘           │
│                             │
│  备注                      │
│  ┌─────────────────────┐   │
│  │                   │   │
│  └─────────────────────┘   │
│                             │
│         [保存]              │
└─────────────────────────────┘
```

#### 设计要点
- **表单布局**：清晰的表单设计
- **标签选择**：借鉴番茄Todo的标签选择器
- **时长输入**：使用数字滚轮选择器
- **保存按钮**：底部固定，易于点击

---

### 白噪音页（V1.1）

#### 布局结构
```
┌─────────────────────────────┐
│  白噪音                    │
├─────────────────────────────┤
│  ┌─────────────────────┐   │
│  │ 🌧️ 雨声           │   │
│  │ [▶] 音量: 80%     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ ☕ 咖啡厅         │   │
│  │ [▶] 音量: 60%     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🌲 森林           │   │
│  │ [▶] 音量: 0%      │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🎵 我的音频       │   │
│  │ [▶] 音量: 50%     │   │
│  └─────────────────────┘   │
│                             │
│         [+ 导入音频]         │
└─────────────────────────────┘
```

#### 设计要点
- **卡片式列表**：每个白噪音一个卡片
- **播放控制**：播放/暂停按钮 + 音量滑块
- **图标**：使用Emoji图标，简洁可爱
- **导入按钮**：底部固定，易于点击

---

## 🎯 交互设计

### 1. 按钮交互

#### 主要按钮（开始/暂停/停止）
- **尺寸**：最小 44pt × 44pt
- **点击反馈**：按下时缩小 5%
- **动画时长**：150ms
- **圆角**：12pt
- **阴影**：按下时阴影消失

#### 次要按钮
- **尺寸**：最小 40pt × 40pt
- **点击反馈**：按下时透明度 0.8
- **动画时长**：100ms

### 2. 列表交互

#### 滑动操作（借鉴番茄Todo）
- **左滑**：显示删除按钮（红色）
- **右滑**：显示编辑按钮（蓝色）
- **滑动距离**：最小 80pt
- **弹性效果**：超过最大距离有弹性

#### 点击操作
- **单击**：展开详情
- **长按**：显示操作菜单
- **长按时间**：300ms

### 3. 进度反馈

#### 进度环（借鉴专注森林）
- **动画**：平滑过渡，使用 Curves.easeInOut
- **颜色**：渐变色（primary → accent）
- **宽度**：8pt
- **更新频率**：每秒更新

#### 进度条
- **动画**：平滑过渡
- **颜色**：accent
- **高度**：4pt
- **圆角**：2pt

### 4. 页面切换

#### 底部导航切换
- **动画**：淡入淡出
- **时长**：200ms
- **曲线**：Curves.easeInOut

#### 页面推入
- **动画**：从右侧滑入
- **时长**：300ms
- **曲线**：Curves.easeOutCubic

### 5. 弹窗交互

#### 确认弹窗
- **背景**：半透明黑色（alpha 0.5）
- **动画**：从下方滑入
- **时长**：250ms
- **圆角**：16pt

#### 提示弹窗（Toast）
- **位置**：屏幕底部
- **显示时长**：2秒
- **动画**：淡入淡出
- **圆角**：8pt

---

## 🎨 组件设计

### 1. 计时器组件

```dart
class TimerDisplay extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 进度环
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: remaining.inSeconds / total.inSeconds,
            strokeWidth: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        SizedBox(height: 32),
        // 时间显示
        Text(
          _formatDuration(remaining),
          style: AppTextStyles.timerDisplay,
        ),
      ],
    );
  }
}
```

### 2. 数据卡片组件

```dart
class DataCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.sm),
          ],
          Text(
            title,
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.h2,
          ),
        ],
      ),
    );
  }
}
```

### 3. 历史记录卡片组件

```dart
class HistoryCard extends StatelessWidget {
  final FocusSession session;
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id.toString()),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // 删除
        } else {
          // 编辑
        }
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            // 时间
            Text(
              _formatTime(session.startTime),
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(width: AppSpacing.md),
            // 时长
            Expanded(
              child: Text(
                '${session.actualDuration}分钟',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            // 标签
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                session.sceneTag?.name ?? '无标签',
                style: AppTextStyles.bodySmall,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // 完成状态
            Icon(
              session.isCompleted ? Icons.check_circle : Icons.cancel,
              color: session.isCompleted 
                ? AppColors.success 
                : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🌓 主题切换

### 浅色模式
- 背景：#F8F9FA
- 表面：#FFFFFF
- 文字：#212529

### 深色模式
- 背景：#1A1A1A
- 表面：#2D2D2D
- 文字：#E9ECEF

### 切换动画
- 时长：300ms
- 曲线：Curves.easeInOut
- 方式：颜色渐变

---

## 📐 响应式设计

### 手机竖屏
- 最小宽度：320pt
- 标准宽度：375pt
- 最大宽度：428pt

### 平板横屏
- 最小宽度：768pt
- 标准宽度：1024pt
- 最大宽度：1366pt

### 适配策略
- 使用 `LayoutBuilder` 动态计算
- 使用 `MediaQuery` 获取屏幕尺寸
- 使用 `Flexible` 和 `Expanded` 自适应布局

---

## ♿ 无障碍设计

### 字体缩放
- 支持系统字体缩放设置
- 最小字体：12pt
- 最大字体：24pt

### 屏幕阅读器
- 所有按钮添加语义标签
- 图片添加描述
- 使用 `Semantics` 组件

### 颜色对比度
- 文字对比度 >= 4.5:1
- 大文字对比度 >= 3:1
- 使用工具检查对比度

---

## 🎭 动画设计

### 1. 页面切换动画
```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

### 2. 按钮点击动画
```dart
GestureDetector(
  onTapDown: (_) {
    // 按下效果
  },
  onTapUp: (_) {
    // 抬起效果
  },
  onTapCancel: () {
    // 取消效果
  },
  child: AnimatedScale(
    scale: isPressed ? 0.95 : 1.0,
    duration: Duration(milliseconds: 150),
    child: button,
  ),
)
```

### 3. 进度环动画
```dart
AnimatedBuilder(
  animation: progressController,
  builder: (context, child) {
    return CircularProgressIndicator(
      value: progressController.value,
      strokeWidth: 8,
      backgroundColor: AppColors.surfaceVariant,
      valueColor: AlwaysStoppedAnimation(AppColors.accent),
    );
  },
)
```

---

## 📊 设计交付物

### 1. 设计稿
- [ ] 首页设计稿（浅色/深色）
- [ ] 历史记录页设计稿
- [ ] 复盘页设计稿（免费版/高级版）
- [ ] 设置页设计稿
- [ ] 手动补录页设计稿
- [ ] 白噪音页设计稿

### 2. 组件库
- [ ] 按钮组件
- [ ] 卡片组件
- [ ] 输入框组件
- [ ] 开关组件
- [ ] 进度环组件
- [ ] 列表组件

### 3. 图标资源
- [ ] 应用图标（各尺寸）
- [ ] 导航图标
- [ ] 功能图标
- [ ] 场景标签图标

---

*最后更新: 2026-03-07*
*版本: 1.0*
