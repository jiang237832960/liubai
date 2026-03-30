import 'package:flutter/material.dart';

/// 留白会话模型
class LiubaiSession {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDuration; // 计划专注时长（分钟）
  final int? actualDuration; // 实际专注时长（分钟）
  final bool isCompleted;
  final String? sceneTemplateId; // 场景模板ID（替代原 sceneTagId）
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  LiubaiSession({
    this.id,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration,
    this.isCompleted = false,
    this.sceneTemplateId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'planned_duration': plannedDuration,
      'actual_duration': actualDuration,
      'is_completed': isCompleted ? 1 : 0,
      'scene_template_id': sceneTemplateId,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory LiubaiSession.fromMap(Map<String, dynamic> map) {
    return LiubaiSession(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'])
          : null,
      plannedDuration: map['planned_duration'],
      actualDuration: map['actual_duration'],
      isCompleted: map['is_completed'] == 1,
      sceneTemplateId: map['scene_template_id'] as String?,
      note: map['note'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  LiubaiSession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDuration,
    int? actualDuration,
    bool? isCompleted,
    String? sceneTemplateId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiubaiSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      sceneTemplateId: sceneTemplateId ?? this.sceneTemplateId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 场景标签模型
class SceneTag {
  final int? id;
  final String name; // 标签名称
  final int color; // 标签颜色（ARGB）
  final int sortOrder; // 排序
  final bool isDefault; // 是否默认标签
  final DateTime createdAt;

  SceneTag({
    this.id,
    required this.name,
    required this.color,
    this.sortOrder = 0,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SceneTag.fromMap(Map<String, dynamic> map) {
    return SceneTag(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      sortOrder: map['sort_order'] ?? 0,
      isDefault: map['is_default'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  SceneTag copyWith({
    int? id,
    String? name,
    int? color,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return SceneTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取颜色对象
  Color get colorValue => Color(color);

  /// 预设标签
  static List<SceneTag> get presets {
    final now = DateTime.now();
    return [
      SceneTag(
        name: '学习',
        color: const Color(0xFF4A90D9).value,
        isDefault: true,
        createdAt: now,
      ),
      SceneTag(
        name: '工作',
        color: const Color(0xFFE74C3C).value,
        isDefault: true,
        createdAt: now,
      ),
      SceneTag(
        name: '阅读',
        color: const Color(0xFF27AE60).value,
        isDefault: true,
        createdAt: now,
      ),
      SceneTag(
        name: '写作',
        color: const Color(0xFFF39C12).value,
        isDefault: true,
        createdAt: now,
      ),
      SceneTag(
        name: '运动',
        color: const Color(0xFF9B59B6).value,
        isDefault: true,
        createdAt: now,
      ),
      SceneTag(
        name: '冥想',
        color: const Color(0xFF1ABC9C).value,
        isDefault: true,
        createdAt: now,
      ),
    ];
  }
}

/// 每日统计模型
class DailyStats {
  final String date; // YYYY-MM-DD
  final int totalDuration; // 总专注时长（分钟）
  final int sessionCount; // 会话次数
  final int completedCount; // 完成次数

  DailyStats({
    required this.date,
    required this.totalDuration,
    required this.sessionCount,
    required this.completedCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'total_duration': totalDuration,
      'session_count': sessionCount,
      'completed_count': completedCount,
    };
  }

  factory DailyStats.fromMap(Map<String, dynamic> map) {
    return DailyStats(
      date: map['date'],
      totalDuration: map['total_duration'],
      sessionCount: map['session_count'],
      completedCount: map['completed_count'],
    );
  }
}

/// 用户设置模型
class UserSettings {
  final int id;
  final int defaultDuration; // 默认专注时长（分钟）
  final bool enableSound;
  final bool enableNotification;
  final String themeMode; // 'light', 'dark', 'system'
  final String? defaultSceneTemplateId; // 默认场景模板ID

  UserSettings({
    this.id = 1,
    this.defaultDuration = 25,
    this.enableSound = true,
    this.enableNotification = true,
    this.themeMode = 'system',
    this.defaultSceneTemplateId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'default_duration': defaultDuration,
      'enable_sound': enableSound ? 1 : 0,
      'enable_notification': enableNotification ? 1 : 0,
      'theme_mode': themeMode,
      'default_scene_template_id': defaultSceneTemplateId,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'],
      defaultDuration: map['default_duration'],
      enableSound: map['enable_sound'] == 1,
      enableNotification: map['enable_notification'] == 1,
      themeMode: map['theme_mode'],
      defaultSceneTemplateId: map['default_scene_template_id'] as String?,
    );
  }

  UserSettings copyWith({
    int? id,
    int? defaultDuration,
    bool? enableSound,
    bool? enableNotification,
    String? themeMode,
    String? defaultSceneTemplateId,
  }) {
    return UserSettings(
      id: id ?? this.id,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      enableSound: enableSound ?? this.enableSound,
      enableNotification: enableNotification ?? this.enableNotification,
      themeMode: themeMode ?? this.themeMode,
      defaultSceneTemplateId: defaultSceneTemplateId ?? this.defaultSceneTemplateId,
    );
  }
}

/// 计时器状态枚举
enum TimerStatus {
  idle, // 空闲
  running, // 进行中
  paused, // 暂停
  completed, // 完成
}

/// 计时器状态类
class TimerState {
  final TimerStatus status;
  final Duration remaining;
  final Duration total;
  final DateTime? startTime;
  final String? sceneTemplateId; // 当前选择的场景模板ID

  TimerState({
    this.status = TimerStatus.idle,
    this.remaining = const Duration(minutes: 25),
    this.total = const Duration(minutes: 25),
    this.startTime,
    this.sceneTemplateId,
  });

  TimerState copyWith({
    TimerStatus? status,
    Duration? remaining,
    Duration? total,
    DateTime? startTime,
    String? sceneTemplateId,
  }) {
    return TimerState(
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      startTime: startTime ?? this.startTime,
      sceneTemplateId: sceneTemplateId ?? this.sceneTemplateId,
    );
  }

  double get progress {
    if (total.inSeconds == 0) return 0;
    return remaining.inSeconds / total.inSeconds;
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isIdle => status == TimerStatus.idle;
  bool get isCompleted => status == TimerStatus.completed;
}
