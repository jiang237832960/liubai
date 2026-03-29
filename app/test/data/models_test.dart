import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:liubai/data/models.dart';

void main() {
  group('LiubaiSession Tests', () {
    test('should create LiubaiSession with default values', () {
      final now = DateTime.now();
      final session = LiubaiSession(
        startTime: now,
        plannedDuration: 25,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.id, isNull);
      expect(session.startTime, equals(now));
      expect(session.plannedDuration, equals(25));
      expect(session.isCompleted, isFalse);
      expect(session.sceneTagId, isNull);
      expect(session.note, isNull);
    });

    test('should convert LiubaiSession to map correctly', () {
      final now = DateTime.now();
      final session = LiubaiSession(
        id: 1,
        startTime: now,
        endTime: now.add(const Duration(minutes: 25)),
        plannedDuration: 25,
        actualDuration: 25,
        isCompleted: true,
        sceneTagId: 2,
        note: 'Test note',
        createdAt: now,
        updatedAt: now,
      );

      final map = session.toMap();

      expect(map['id'], equals(1));
      expect(map['start_time'], equals(now.millisecondsSinceEpoch));
      expect(map['planned_duration'], equals(25));
      expect(map['is_completed'], equals(1));
      expect(map['scene_tag_id'], equals(2));
      expect(map['note'], equals('Test note'));
    });

    test('should create LiubaiSession from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'start_time': now.millisecondsSinceEpoch,
        'end_time': now.add(const Duration(minutes: 25)).millisecondsSinceEpoch,
        'planned_duration': 25,
        'actual_duration': 25,
        'is_completed': 1,
        'scene_tag_id': 2,
        'note': 'Test note',
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final session = LiubaiSession.fromMap(map);

      expect(session.id, equals(1));
      expect(session.plannedDuration, equals(25));
      expect(session.isCompleted, isTrue);
      expect(session.sceneTagId, equals(2));
      expect(session.note, equals('Test note'));
    });

    test('should handle null values in fromMap', () {
      final now = DateTime.now();
      final map = {
        'id': null,
        'start_time': now.millisecondsSinceEpoch,
        'end_time': null,
        'planned_duration': 25,
        'actual_duration': null,
        'is_completed': 0,
        'scene_tag_id': null,
        'note': null,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      final session = LiubaiSession.fromMap(map);

      expect(session.id, isNull);
      expect(session.endTime, isNull);
      expect(session.actualDuration, isNull);
      expect(session.isCompleted, isFalse);
      expect(session.sceneTagId, isNull);
      expect(session.note, isNull);
    });

    test('copyWith should create a copy with updated values', () {
      final now = DateTime.now();
      final session = LiubaiSession(
        id: 1,
        startTime: now,
        plannedDuration: 25,
        createdAt: now,
        updatedAt: now,
      );

      final updatedSession = session.copyWith(
        isCompleted: true,
        actualDuration: 25,
      );

      expect(updatedSession.id, equals(1));
      expect(updatedSession.isCompleted, isTrue);
      expect(updatedSession.actualDuration, equals(25));
      expect(updatedSession.plannedDuration, equals(25)); // unchanged
    });
  });

  group('SceneTag Tests', () {
    test('should create SceneTag with correct values', () {
      final now = DateTime.now();
      final tag = SceneTag(
        id: 1,
        name: '测试标签',
        color: const Color(0xFF4A90D9).value,
        sortOrder: 0,
        isDefault: false,
        createdAt: now,
      );

      expect(tag.id, equals(1));
      expect(tag.name, equals('测试标签'));
      expect(tag.color, equals(const Color(0xFF4A90D9).value));
      expect(tag.sortOrder, equals(0));
      expect(tag.isDefault, isFalse);
    });

    test('should convert SceneTag to map correctly', () {
      final now = DateTime.now();
      final tag = SceneTag(
        id: 1,
        name: '测试标签',
        color: const Color(0xFF4A90D9).value,
        sortOrder: 2,
        isDefault: true,
        createdAt: now,
      );

      final map = tag.toMap();

      expect(map['id'], equals(1));
      expect(map['name'], equals('测试标签'));
      expect(map['color'], equals(const Color(0xFF4A90D9).value));
      expect(map['sort_order'], equals(2));
      expect(map['is_default'], equals(1));
    });

    test('should create SceneTag from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 1,
        'name': '测试标签',
        'color': const Color(0xFF4A90D9).value,
        'sort_order': 2,
        'is_default': 1,
        'created_at': now.millisecondsSinceEpoch,
      };

      final tag = SceneTag.fromMap(map);

      expect(tag.id, equals(1));
      expect(tag.name, equals('测试标签'));
      expect(tag.isDefault, isTrue);
    });

    test('colorValue should return Color object', () {
      final now = DateTime.now();
      final tag = SceneTag(
        name: '测试',
        color: const Color(0xFF4A90D9).value,
        createdAt: now,
      );

      expect(tag.colorValue, isA<Color>());
      expect(tag.colorValue.value, equals(const Color(0xFF4A90D9).value));
    });

    test('presets should return 6 default tags', () {
      final presets = SceneTag.presets;

      expect(presets.length, equals(6));
      expect(presets[0].name, equals('学习'));
      expect(presets[1].name, equals('工作'));
      expect(presets[2].name, equals('阅读'));
      expect(presets[3].name, equals('写作'));
      expect(presets[4].name, equals('运动'));
      expect(presets[5].name, equals('冥想'));
    });

    test('copyWith should create a copy with updated values', () {
      final now = DateTime.now();
      final tag = SceneTag(
        id: 1,
        name: '测试',
        color: const Color(0xFF4A90D9).value,
        createdAt: now,
      );

      final updatedTag = tag.copyWith(name: '更新名称');

      expect(updatedTag.id, equals(1));
      expect(updatedTag.name, equals('更新名称'));
      expect(updatedTag.color, equals(tag.color)); // unchanged
    });
  });

  group('UserSettings Tests', () {
    test('should create UserSettings with default values', () {
      final settings = UserSettings();

      expect(settings.id, equals(1));
      expect(settings.defaultDuration, equals(25));
      expect(settings.enableSound, isTrue);
      expect(settings.enableNotification, isTrue);
      expect(settings.themeMode, equals('system'));
      expect(settings.defaultSceneTagId, isNull);
    });

    test('should convert UserSettings to map correctly', () {
      final settings = UserSettings(
        id: 1,
        defaultDuration: 30,
        enableSound: false,
        enableNotification: false,
        themeMode: 'dark',
        defaultSceneTagId: 2,
      );

      final map = settings.toMap();

      expect(map['id'], equals(1));
      expect(map['default_duration'], equals(30));
      expect(map['enable_sound'], equals(0));
      expect(map['enable_notification'], equals(0));
      expect(map['theme_mode'], equals('dark'));
      expect(map['default_scene_tag_id'], equals(2));
    });

    test('should create UserSettings from map correctly', () {
      final map = {
        'id': 1,
        'default_duration': 30,
        'enable_sound': 0,
        'enable_notification': 0,
        'theme_mode': 'dark',
        'default_scene_tag_id': 2,
      };

      final settings = UserSettings.fromMap(map);

      expect(settings.defaultDuration, equals(30));
      expect(settings.enableSound, isFalse);
      expect(settings.enableNotification, isFalse);
      expect(settings.themeMode, equals('dark'));
      expect(settings.defaultSceneTagId, equals(2));
    });

    test('copyWith should create a copy with updated values', () {
      final settings = UserSettings();

      final updatedSettings = settings.copyWith(
        defaultDuration: 45,
        themeMode: 'light',
      );

      expect(updatedSettings.defaultDuration, equals(45));
      expect(updatedSettings.themeMode, equals('light'));
      expect(updatedSettings.enableSound, isTrue); // unchanged
    });
  });

  group('DailyStats Tests', () {
    test('should create DailyStats with correct values', () {
      final stats = DailyStats(
        date: '2026-03-08',
        totalDuration: 120,
        sessionCount: 5,
        completedCount: 4,
      );

      expect(stats.date, equals('2026-03-08'));
      expect(stats.totalDuration, equals(120));
      expect(stats.sessionCount, equals(5));
      expect(stats.completedCount, equals(4));
    });

    test('should convert DailyStats to map correctly', () {
      final stats = DailyStats(
        date: '2026-03-08',
        totalDuration: 120,
        sessionCount: 5,
        completedCount: 4,
      );

      final map = stats.toMap();

      expect(map['date'], equals('2026-03-08'));
      expect(map['total_duration'], equals(120));
      expect(map['session_count'], equals(5));
      expect(map['completed_count'], equals(4));
    });

    test('should create DailyStats from map correctly', () {
      final map = {
        'date': '2026-03-08',
        'total_duration': 120,
        'session_count': 5,
        'completed_count': 4,
      };

      final stats = DailyStats.fromMap(map);

      expect(stats.date, equals('2026-03-08'));
      expect(stats.totalDuration, equals(120));
    });
  });

  group('TimerState Tests', () {
    test('should create TimerState with default values', () {
      final state = TimerState();

      expect(state.status, equals(TimerStatus.idle));
      expect(state.remaining, equals(const Duration(minutes: 25)));
      expect(state.total, equals(const Duration(minutes: 25)));
      expect(state.startTime, isNull);
      expect(state.sceneTagId, isNull);
    });

    test('copyWith should create a copy with updated values', () {
      final state = TimerState();

      final updatedState = state.copyWith(
        status: TimerStatus.running,
        remaining: const Duration(minutes: 20),
      );

      expect(updatedState.status, equals(TimerStatus.running));
      expect(updatedState.remaining, equals(const Duration(minutes: 20)));
      expect(updatedState.total, equals(const Duration(minutes: 25))); // unchanged
    });

    test('progress should calculate correctly', () {
      final state = TimerState(
        remaining: const Duration(minutes: 12),
        total: const Duration(minutes: 24),
      );

      expect(state.progress, equals(0.5));
    });

    test('status getters should work correctly', () {
      final idleState = TimerState(status: TimerStatus.idle);
      final runningState = TimerState(status: TimerStatus.running);
      final pausedState = TimerState(status: TimerStatus.paused);
      final completedState = TimerState(status: TimerStatus.completed);

      expect(idleState.isIdle, isTrue);
      expect(runningState.isRunning, isTrue);
      expect(pausedState.isPaused, isTrue);
      expect(completedState.isCompleted, isTrue);
    });
  });
}
