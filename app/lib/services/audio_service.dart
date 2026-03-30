import 'package:just_audio/just_audio.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';

enum WhiteNoiseType {
  rain,
  rainHeavy,
  thunder,
  forest,
  crickets,
  birds,
  cafe,
  oceanWaves,
  fire,
  pages,
  custom,
}

class WhiteNoise {
  final String id;
  final String name;
  final String emoji;
  final WhiteNoiseType type;
  final String? assetPath;
  final String? filePath;
  double volume;
  bool isPlaying;

  WhiteNoise({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    this.assetPath,
    this.filePath,
    this.volume = 0.5,
    this.isPlaying = false,
  });

  bool get isBuiltIn => type != WhiteNoiseType.custom;

  WhiteNoise copyWith({
    String? id,
    String? name,
    String? emoji,
    WhiteNoiseType? type,
    String? assetPath,
    String? filePath,
    double? volume,
    bool? isPlaying,
  }) {
    return WhiteNoise(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      assetPath: assetPath ?? this.assetPath,
      filePath: filePath ?? this.filePath,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class BuiltInNoiseConfig {
  final String id;
  final String name;
  final String emoji;
  final WhiteNoiseType type;
  final String assetPath;

  const BuiltInNoiseConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.assetPath,
  });
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const String _tag = 'Audio';

  static const List<BuiltInNoiseConfig> _builtInConfigs = [
    BuiltInNoiseConfig(
      id: 'rain',
      name: '雨声',
      emoji: '🌧️',
      type: WhiteNoiseType.rain,
      assetPath: 'assets/audio/rain.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'rain_heavy',
      name: '暴雨',
      emoji: '⛈️',
      type: WhiteNoiseType.rainHeavy,
      assetPath: 'assets/audio/rain_heavy.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'thunder',
      name: '雷声',
      emoji: '⚡',
      type: WhiteNoiseType.thunder,
      assetPath: 'assets/audio/thunder.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'forest',
      name: '森林',
      emoji: '🌲',
      type: WhiteNoiseType.forest,
      assetPath: 'assets/audio/forest.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'crickets',
      name: '虫鸣',
      emoji: '🦗',
      type: WhiteNoiseType.crickets,
      assetPath: 'assets/audio/crickets.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'birds',
      name: '鸟鸣',
      emoji: '🐦',
      type: WhiteNoiseType.birds,
      assetPath: 'assets/audio/birds.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'cafe',
      name: '咖啡厅',
      emoji: '☕',
      type: WhiteNoiseType.cafe,
      assetPath: 'assets/audio/cafe.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'ocean_waves',
      name: '海浪',
      emoji: '🌊',
      type: WhiteNoiseType.oceanWaves,
      assetPath: 'assets/audio/ocean_waves.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'fire',
      name: '篝火',
      emoji: '🔥',
      type: WhiteNoiseType.fire,
      assetPath: 'assets/audio/fire.mp3',
    ),
    BuiltInNoiseConfig(
      id: 'pages',
      name: '翻书',
      emoji: '📖',
      type: WhiteNoiseType.pages,
      assetPath: 'assets/audio/pages.mp3',
    ),
  ];

  final AudioPlayer _player = AudioPlayer();
  WhiteNoise? _currentNoise;
  bool _isInitialized = false;

  final List<WhiteNoise> _builtInNoises = [];
  List<WhiteNoise> _customNoises = [];

  List<WhiteNoise> get builtInNoises => _builtInNoises;
  List<WhiteNoise> get customNoises => _customNoises;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _player.playerStateStream.listen((state) {
        Logger.d('播放器状态: ${state.processingState}', tag: _tag);
      });

      _player.playbackEventStream.listen(
        (event) {
          Logger.d('播放事件', tag: _tag);
        },
        onError: (Object e, StackTrace st) {
          Logger.e('播放事件错误', tag: _tag, error: e, stackTrace: st);
        },
      );

      _loadBuiltInNoises();

      _isInitialized = true;
      Logger.i('音频服务初始化完成', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('音频服务初始化失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '音频服务初始化失败',
        code: 'AUDIO_INIT_ERROR',
        originalError: e,
      );
    }
  }

  void _loadBuiltInNoises() {
    for (final config in _builtInConfigs) {
      _builtInNoises.add(WhiteNoise(
        id: config.id,
        name: config.name,
        emoji: config.emoji,
        type: config.type,
        assetPath: config.assetPath,
      ));
    }
  }

  List<WhiteNoise> get allNoises => [..._builtInNoises, ..._customNoises];

  WhiteNoise? get currentNoise => _currentNoise;

  bool get isPlaying => _player.playing;

  Future<void> play(WhiteNoise noise) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      Logger.i('开始播放: ${noise.name}', tag: _tag);

      await stop();

      if (noise.assetPath != null) {
        await _player.setAsset(noise.assetPath!);
      } else if (noise.filePath != null) {
        await _player.setFilePath(noise.filePath!);
      } else {
        throw const AudioException(
          '无效的音频源',
          code: 'AUDIO_INVALID_SOURCE',
        );
      }

      await _player.setVolume(noise.volume);
      await _player.setLoopMode(LoopMode.all);
      await _player.play();

      _currentNoise = noise;
      noise.isPlaying = true;

      Logger.i('播放成功: ${noise.name}', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('播放失败: ${noise.name}', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '播放失败: ${noise.name}',
        code: 'AUDIO_PLAY_ERROR',
        originalError: e,
      );
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      if (_currentNoise != null) {
        _currentNoise!.isPlaying = false;
      }
      Logger.i('暂停播放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('暂停失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '暂停失败',
        code: 'AUDIO_PAUSE_ERROR',
        originalError: e,
      );
    }
  }

  Future<void> resume() async {
    try {
      await _player.play();
      if (_currentNoise != null) {
        _currentNoise!.isPlaying = true;
      }
      Logger.i('恢复播放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('恢复播放失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '恢复播放失败',
        code: 'AUDIO_RESUME_ERROR',
        originalError: e,
      );
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      if (_currentNoise != null) {
        _currentNoise!.isPlaying = false;
        _currentNoise = null;
      }
      Logger.d('停止播放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('停止播放失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '停止播放失败',
        code: 'AUDIO_STOP_ERROR',
        originalError: e,
      );
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
      if (_currentNoise != null) {
        _currentNoise!.volume = clampedVolume;
      }
      // 同时更新所有 builtInNoises 中对应 id 的音量和 customNoises 的音量
      for (var i = 0; i < _builtInNoises.length; i++) {
        if (_builtInNoises[i].id == _currentNoise?.id) {
          _builtInNoises[i].volume = clampedVolume;
        }
      }
      for (var i = 0; i < _customNoises.length; i++) {
        if (_customNoises[i].id == _currentNoise?.id) {
          _customNoises[i].volume = clampedVolume;
        }
      }
      Logger.d('设置音量: $clampedVolume', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('设置音量失败', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '设置音量失败',
        code: 'AUDIO_VOLUME_ERROR',
        originalError: e,
      );
    }
  }

  Future<void> toggle(WhiteNoise noise) async {
    if (_currentNoise?.id == noise.id && _player.playing) {
      await pause();
    } else {
      await play(noise);
    }
  }

  void addCustomNoise(WhiteNoise noise) {
    _customNoises.add(noise);
    Logger.i('添加自定义白噪音: ${noise.name}', tag: _tag);
  }

  Future<void> removeCustomNoise(String id) async {
    try {
      if (_currentNoise?.id == id) {
        await stop();
      }
      _customNoises.removeWhere((noise) => noise.id == id);
      Logger.i('删除自定义白噪音: $id', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('删除白噪音失败: $id', tag: _tag, error: e, stackTrace: stackTrace);
      throw AudioException(
        '删除白噪音失败',
        code: 'AUDIO_REMOVE_ERROR',
        originalError: e,
      );
    }
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
      _isInitialized = false;
      Logger.i('音频服务已释放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('释放音频服务失败', tag: _tag, error: e, stackTrace: stackTrace);
    }
  }
}
