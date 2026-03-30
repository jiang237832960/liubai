import 'package:flutter/material.dart';

enum SegmentType {
  work,
  rest,
}

enum SoundSourceType {
  builtIn,
  custom,
}

class SoundSource {
  final String id;
  final String name;
  final String emoji;
  final SoundSourceType sourceType;
  final String assetPath;
  final String? filePath;

  const SoundSource({
    required this.id,
    required this.name,
    required this.emoji,
    required this.sourceType,
    required this.assetPath,
    this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'sourceType': sourceType.index,
      'assetPath': assetPath,
      'filePath': filePath,
    };
  }

  factory SoundSource.fromMap(Map<String, dynamic> map) {
    return SoundSource(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      sourceType: SoundSourceType.values[map['sourceType'] as int],
      assetPath: map['assetPath'] as String,
      filePath: map['filePath'] as String?,
    );
  }

  SoundSource copyWith({
    String? id,
    String? name,
    String? emoji,
    SoundSourceType? sourceType,
    String? assetPath,
    String? filePath,
  }) {
    return SoundSource(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      sourceType: sourceType ?? this.sourceType,
      assetPath: assetPath ?? this.assetPath,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundSource && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AudioTrack {
  final String id;
  final String name;
  final double volume;
  final int fadeInDuration;
  final int fadeOutDuration;
  final SoundSource soundSource;

  const AudioTrack({
    required this.id,
    required this.name,
    required this.volume,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    required this.soundSource,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'volume': volume,
      'fadeInDuration': fadeInDuration,
      'fadeOutDuration': fadeOutDuration,
      'soundSource': soundSource.toMap(),
    };
  }

  factory AudioTrack.fromMap(Map<String, dynamic> map) {
    return AudioTrack(
      id: map['id'] as String,
      name: map['name'] as String,
      volume: (map['volume'] as num).toDouble(),
      fadeInDuration: map['fadeInDuration'] as int,
      fadeOutDuration: map['fadeOutDuration'] as int,
      soundSource: SoundSource.fromMap(map['soundSource'] as Map<String, dynamic>),
    );
  }

  AudioTrack copyWith({
    String? id,
    String? name,
    double? volume,
    int? fadeInDuration,
    int? fadeOutDuration,
    SoundSource? soundSource,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      volume: volume ?? this.volume,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      soundSource: soundSource ?? this.soundSource,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioTrack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TrackRef {
  final String trackId;
  final double volume;

  const TrackRef({
    required this.trackId,
    required this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'trackId': trackId,
      'volume': volume,
    };
  }

  factory TrackRef.fromMap(Map<String, dynamic> map) {
    return TrackRef(
      trackId: map['trackId'] as String,
      volume: (map['volume'] as num).toDouble(),
    );
  }
}

class TimeSegment {
  final String id;
  final SegmentType type;
  final int startOffsetMs;
  final int durationMs;
  final List<TrackRef> trackRefs;

  const TimeSegment({
    required this.id,
    required this.type,
    required this.startOffsetMs,
    required this.durationMs,
    required this.trackRefs,
  });

  int get endOffsetMs => startOffsetMs + durationMs;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'startOffsetMs': startOffsetMs,
      'durationMs': durationMs,
      'trackRefs': trackRefs.map((r) => r.toMap()).toList(),
    };
  }

  factory TimeSegment.fromMap(Map<String, dynamic> map) {
    return TimeSegment(
      id: map['id'] as String,
      type: SegmentType.values[map['type'] as int],
      startOffsetMs: map['startOffsetMs'] as int,
      durationMs: map['durationMs'] as int,
      trackRefs: (map['trackRefs'] as List)
          .map((r) => TrackRef.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  TimeSegment copyWith({
    String? id,
    SegmentType? type,
    int? startOffsetMs,
    int? durationMs,
    List<TrackRef>? trackRefs,
  }) {
    return TimeSegment(
      id: id ?? this.id,
      type: type ?? this.type,
      startOffsetMs: startOffsetMs ?? this.startOffsetMs,
      durationMs: durationMs ?? this.durationMs,
      trackRefs: trackRefs ?? this.trackRefs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSegment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SceneTemplate {
  final String id;
  final String name;
  final String emoji;
  final int cycles;
  final int workDurationMs;
  final int restDurationMs;
  final List<AudioTrack> audioTracks;
  final List<TimeSegment> segments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SceneTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cycles,
    required this.workDurationMs,
    required this.restDurationMs,
    required this.audioTracks,
    required this.segments,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalDurationMs {
    final oneCycleDuration = workDurationMs + restDurationMs;
    return oneCycleDuration * cycles;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'cycles': cycles,
      'workDurationMs': workDurationMs,
      'restDurationMs': restDurationMs,
      'audioTracks': audioTracks.map((t) => t.toMap()).toList(),
      'segments': segments.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SceneTemplate.fromMap(Map<String, dynamic> map) {
    return SceneTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      cycles: map['cycles'] as int,
      workDurationMs: map['workDurationMs'] as int,
      restDurationMs: map['restDurationMs'] as int,
      audioTracks: (map['audioTracks'] as List)
          .map((t) => AudioTrack.fromMap(t as Map<String, dynamic>))
          .toList(),
      segments: (map['segments'] as List)
          .map((s) => TimeSegment.fromMap(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  SceneTemplate copyWith({
    String? id,
    String? name,
    String? emoji,
    int? cycles,
    int? workDurationMs,
    int? restDurationMs,
    List<AudioTrack>? audioTracks,
    List<TimeSegment>? segments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SceneTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      cycles: cycles ?? this.cycles,
      workDurationMs: workDurationMs ?? this.workDurationMs,
      restDurationMs: restDurationMs ?? this.restDurationMs,
      audioTracks: audioTracks ?? this.audioTracks,
      segments: segments ?? this.segments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static SceneTemplate defaultPomodoro() {
    final now = DateTime.now();
    const workDuration = 25 * 60 * 1000;
    const restDuration = 5 * 60 * 1000;

    return SceneTemplate(
      id: 'default_pomodoro',
      name: '标准番茄钟',
      emoji: '🍅',
      cycles: 4,
      workDurationMs: workDuration,
      restDurationMs: restDuration,
      audioTracks: const [],
      segments: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SceneTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BuiltInAudioLibrary {
  static const List<SoundSource> sources = [
    SoundSource(
      id: 'rain',
      name: '雨声',
      emoji: '🌧️',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/rain.mp3',
    ),
    SoundSource(
      id: 'rain_heavy',
      name: '暴雨',
      emoji: '⛈️',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/rain_heavy.mp3',
    ),
    SoundSource(
      id: 'thunder',
      name: '雷声',
      emoji: '⚡',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/thunder.mp3',
    ),
    SoundSource(
      id: 'forest',
      name: '森林',
      emoji: '🌲',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/forest.mp3',
    ),
    SoundSource(
      id: 'crickets',
      name: '虫鸣',
      emoji: '🦗',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/crickets.mp3',
    ),
    SoundSource(
      id: 'birds',
      name: '鸟鸣',
      emoji: '🐦',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/birds.mp3',
    ),
    SoundSource(
      id: 'cafe',
      name: '咖啡厅',
      emoji: '☕',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/cafe.mp3',
    ),
    SoundSource(
      id: 'ocean_waves',
      name: '海浪',
      emoji: '🌊',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/ocean_waves.mp3',
    ),
    SoundSource(
      id: 'fire',
      name: '篝火',
      emoji: '🔥',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/fire.mp3',
    ),
    SoundSource(
      id: 'pages',
      name: '翻书',
      emoji: '📖',
      sourceType: SoundSourceType.builtIn,
      assetPath: 'assets/audio/pages.mp3',
    ),
  ];

  static SoundSource? getById(String id) {
    try {
      return sources.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
