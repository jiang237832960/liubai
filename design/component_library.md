# 秒启专注 - 组件库规范

## 📋 组件库概览

本文档定义秒启专注应用的所有可复用UI组件，确保设计一致性和开发效率。

---

## 🎨 基础组件

### 1. 按钮 (AppButton)

#### 主要按钮 (Primary)
```dart
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonSize size;
  final AppButtonType type;
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: type == AppButtonType.primary 
          ? AppColors.accent 
          : AppColors.surfaceVariant,
        foregroundColor: type == AppButtonType.primary 
          ? Colors.white 
          : AppColors.textPrimary,
        minimumSize: _getSize(size),
        padding: _getPadding(size),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 0,
      ),
      child: isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Text(
            text,
            style: AppTextStyles.button,
          ),
    );
  }
}
```

#### 次要按钮 (Secondary)
```dart
AppButton(
  text: '取消',
  onPressed: () {},
  type: AppButtonType.secondary,
)
```

#### 危险按钮 (Danger)
```dart
AppButton(
  text: '删除',
  onPressed: () {},
  type: AppButtonType.danger,
)
```

#### 尺寸规范
| 尺寸 | 最小宽度 | 高度 | 字体大小 |
|-----|---------|------|---------|
| Small | 80pt | 36pt | 14pt |
| Medium | 120pt | 44pt | 16pt |
| Large | 160pt | 52pt | 18pt |

---

### 2. 输入框 (AppTextField)

```dart
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLines;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.accent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### 3. 开关 (AppSwitch)

```dart
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(width: AppSpacing.md),
        ],
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withOpacity(0.3),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
```

---

### 4. 卡片 (AppCard)

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isElevated;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isElevated
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
        ),
        child: child,
      ),
    );
  }
}
```

---

### 5. 数据卡片 (DataCard)

```dart
class DataCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      isElevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.textSecondary,
              size: 24,
            ),
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

---

## 🎯 功能组件

### 6. 计时器显示 (TimerDisplay)

```dart
class TimerDisplay extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    final progress = remaining.inSeconds / total.inSeconds;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // 进度环
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景环
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(Colors.transparent),
                ),
                // 进度环
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accent,
                      ],
                    ).createShader(Rect.fromCircle(
                      center: Offset.zero,
                      radius: 140,
                    )),
                  ),
                ),
                // 时间显示
                Text(
                  _formatDuration(remaining),
                  style: AppTextStyles.timerDisplay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
```

---

### 7. 历史记录卡片 (HistoryCard)

```dart
class HistoryCard extends StatelessWidget {
  final FocusSession session;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id.toString()),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
        } else {
          onDelete?.call();
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        color: AppColors.primary,
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        color: AppColors.error,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.all(AppSpacing.md),
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
            if (session.sceneTag != null) ...[
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
                  session.sceneTag!.name,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
            ],
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

### 8. 场景标签选择器 (SceneTagSelector)

```dart
class SceneTagSelector extends StatelessWidget {
  final List<SceneTag> tags;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final VoidCallback? onAddTag;
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ...tags.map((tag) => _buildTagChip(tag)),
        _buildAddButton(),
      ],
    );
  }
  
  Widget _buildTagChip(SceneTag tag) {
    final isSelected = tag.id == selectedId;
    return GestureDetector(
      onTap: () => onSelected(tag.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.accent 
            : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected 
              ? AppColors.accent 
              : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          tag.name,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected 
              ? Colors.white 
              : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
  
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddTag,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: AppColors.textTertiary,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 16,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
```

---

### 9. 白噪音卡片 (WhiteNoiseCard)

```dart
class WhiteNoiseCard extends StatelessWidget {
  final String name;
  final String icon;
  final bool isPlaying;
  final double volume;
  final VoidCallback? onPlayPause;
  final ValueChanged<double>? onVolumeChanged;
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      isElevated: true,
      child: Column(
        children: [
          // 标题和播放按钮
          Row(
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.h3,
                ),
              ),
              IconButton(
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // 音量滑块
          Row(
            children: [
              Icon(Icons.volume_down, size: 16),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: onVolumeChanged,
                  activeColor: AppColors.accent,
                  inactiveColor: AppColors.surfaceVariant,
                ),
              ),
              Icon(Icons.volume_up, size: 16),
              SizedBox(width: AppSpacing.sm),
              Text(
                '${(volume * 100).toInt()}%',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

### 10. 时长选择器 (DurationPicker)

```dart
class DurationPicker extends StatelessWidget {
  final Duration value;
  final ValueChanged<Duration> onChanged;
  
  @override
  Widget build(BuildContext context) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    
    return Row(
      children: [
        // 小时
        Expanded(
          child: Column(
            children: [
              Text(
                '小时',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: AppSpacing.xs),
              _buildNumberPicker(
                value: hours,
                maxValue: 4,
                onChanged: (v) => onChanged(
                  Duration(hours: v, minutes: minutes),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        // 分钟
        Expanded(
          child: Column(
            children: [
              Text(
                '分钟',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: AppSpacing.xs),
              _buildNumberPicker(
                value: minutes,
                maxValue: 59,
                onChanged: (v) => onChanged(
                  Duration(hours: hours, minutes: v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildNumberPicker({
    required int value,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        physics: FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        controller: FixedExtentScrollController(
          initialItem: value,
        ),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue + 1,
          builder: (context, index) {
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: AppTextStyles.h1,
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 🔔 反馈组件

### 11. Toast 提示 (AppToast)

```dart
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastType type = ToastType.info,
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIcon(type)),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: _getBackgroundColor(type),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
  
  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
      default:
        return Icons.info;
    }
  }
  
  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
      default:
        return AppColors.primary;
    }
  }
}
```

---

### 12. 确认弹窗 (ConfirmDialog)

```dart
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.h3),
      content: message != null ? Text(message!) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger 
              ? AppColors.error 
              : AppColors.accent,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
```

---

### 13. 加载指示器 (AppLoading)

```dart
class AppLoading extends StatelessWidget {
  final String? message;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 📊 图表组件

### 14. 趋势折线图 (TrendChart)

```dart
class TrendChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final String title;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data.map((point) => FlSpot(
                    point.x.toDouble(),
                    point.y.toDouble(),
                  )).toList(),
                  isCurved: true,
                  color: AppColors.accent,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### 15. 场景分布饼图 (ScenePieChart)

```dart
class ScenePieChart extends StatelessWidget {
  final Map<String, int> data;
  
  @override
  Widget build(BuildContext context) {
    final total = data.values.reduce((a, b) => a + b);
    final sections = data.entries.map((entry) {
      final percentage = entry.value / total;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${(percentage * 100).toInt()}%',
        color: _getColor(entry.key),
        radius: 50,
      );
    }).toList();
    
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
  
  Color _getColor(String key) {
    final colors = [
      AppColors.accent,
      AppColors.success,
      AppColors.primary,
      AppColors.warning,
    ];
    final index = data.keys.toList().indexOf(key) % colors.length;
    return colors[index];
  }
}
```

---

## 🧭 导航组件

### 16. 底部导航栏 (BottomNavBar)

```dart
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.timer,
                label: '计时',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: '历史',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.bar_chart,
                label: '复盘',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: '设置',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? AppColors.accent 
                : AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected 
                  ? AppColors.accent 
                  : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📋 列表组件

### 17. 空状态 (EmptyState)

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 🔒 锁定组件

### 18. 功能锁定卡片 (LockedFeatureCard)

```dart
class LockedFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onUnlock;
  
  @override
  Widget build(BuildContext context) {
    return AppCard(
      isElevated: true,
      child: Column(
        children: [
          Icon(
            Icons.lock,
            size: 48,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(
            text: '立即解锁',
            onPressed: onUnlock,
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }
}
```

---

## 📐 布局组件

### 19. 分组标题 (SectionHeader)

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
```

---

### 20. 分割线 (Divider)

```dart
class AppDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? AppSpacing.md,
      thickness: thickness ?? 1,
      color: color ?? AppColors.surfaceVariant,
    );
  }
}
```

---

## 🎨 组件使用示例

### 示例1：计时页

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部时间
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                _getCurrentTime(),
                style: AppTextStyles.bodySmall,
              ),
            ),
            // 计时器
            Expanded(
              child: Center(
                child: TimerDisplay(
                  remaining: Duration(minutes: 25),
                  total: Duration(minutes: 25),
                ),
              ),
            ),
            // 按钮
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    text: '开始',
                    onPressed: () {},
                    type: AppButtonType.primary,
                  ),
                  AppButton(
                    text: '暂停',
                    onPressed: () {},
                    type: AppButtonType.secondary,
                  ),
                  AppButton(
                    text: '停止',
                    onPressed: () {},
                    type: AppButtonType.danger,
                  ),
                ],
              ),
            ),
            // 底部导航
            BottomNavBar(
              currentIndex: 0,
              onTap: (index) {},
            ),
          ],
        ),
      ),
    );
  }
}
```

### 示例2：历史记录页

```dart
class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return HistoryCard(
            session: sessions[index],
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          );
        },
      ),
    );
  }
}
```

---

## 📊 组件统计

| 类别 | 组件数量 | 组件列表 |
|-----|---------|---------|
| 基础组件 | 5 | Button, TextField, Switch, Card, DataCard |
| 功能组件 | 5 | TimerDisplay, HistoryCard, SceneTagSelector, WhiteNoiseCard, DurationPicker |
| 反馈组件 | 3 | Toast, ConfirmDialog, Loading |
| 图表组件 | 2 | TrendChart, ScenePieChart |
| 导航组件 | 1 | BottomNavBar |
| 列表组件 | 1 | EmptyState |
| 锁定组件 | 1 | LockedFeatureCard |
| 布局组件 | 2 | SectionHeader, Divider |
| **总计** | **20** | - |

---

## 🎯 组件设计原则

1. **可复用性**：所有组件都应该是可复用的，避免重复代码
2. **一致性**：使用统一的颜色、字体、间距、圆角
3. **可定制性**：通过参数支持不同的使用场景
4. **性能优化**：使用 const 构造函数，避免不必要的重建
5. **无障碍**：所有交互组件都支持无障碍访问

---

*最后更新: 2026-03-07*
*版本: 1.0*
