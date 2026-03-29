import 'package:just_audio/just_audio.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';

/// 白噪音类型
enum WhiteNoiseType {
  rain, // 雨声
  forest, // 森林
  cafe, // 咖啡厅
  waves, // 海浪
  fire, // 篝火
  custom, // 自定义
}

/// 白噪音模型
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

/// 音频服务
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const String _tag = 'Audio';

  final AudioPlayer _player = AudioPlayer();
  WhiteNoise? _currentNoise;
  bool _isInitialized = false;

  // 内置白噪音列表
  final List<WhiteNoise> builtInNoises = [
    WhiteNoise(
      id: 'rain',
      name: '雨声',
      emoji: '🌧️',
      type: WhiteNoiseType.rain,
      assetPath: 'assets/audio/rain.mp3',
    ),
    WhiteNoise(
      id: 'forest',
      name: '森林',
      emoji: '🌲',
      type: WhiteNoiseType.forest,
      assetPath: 'assets/audio/forest.mp3',
    ),
    WhiteNoise(
      id: 'cafe',
      name: '咖啡厅',
      emoji: '☕',
      type: WhiteNoiseType.cafe,
      assetPath: 'assets/audio/cafe.mp3',
    ),
    WhiteNoise(
      id: 'waves',
      name: '海浪',
      emoji: '🌊',
      type: WhiteNoiseType.waves,
      assetPath: 'assets/audio/waves.mp3',
    ),
    WhiteNoise(
      id: 'fire',
      name: '篝火',
      emoji: '🔥',
      type: WhiteNoiseType.fire,
      assetPath: 'assets/audio/fire.mp3',
    ),
  ];

  // 自定义白噪音列表
  List<WhiteNoise> customNoises = [];

  /// 初始化音频服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 监听播放状态
      _player.playerStateStream.listen((state) {
        Logger.d('播放器状态: ${state.processingState}', tag: _tag);
      });

      _player.playbackEventStream.listen(
        (event) {
          Logger.d('播放事件: ${event.eventType}', tag: _tag);
        },
        onError: (Object e, StackTrace st) {
          Logger.e('播放事件错误', tag: _tag, error: e, stackTrace: st);
        },
      );

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

  /// 获取所有白噪音
  List<WhiteNoise> get allNoises => [...builtInNoises, ...customNoises];

  /// 获取当前播放的白噪音
  WhiteNoise? get currentNoise => _currentNoise;

  /// 是否正在播放
  bool get isPlaying => _player.playing;

  /// 播放白噪音
  Future<void> play(WhiteNoise noise) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      Logger.i('开始播放: ${noise.name}', tag: _tag);

      // 停止当前播放
      await stop();

      // 设置音频源
      if (noise.isBuiltIn && noise.assetPath != null) {
        await _player.setAsset(noise.assetPath!);
      } else if (noise.filePath != null) {
        await _player.setFilePath(noise.filePath!);
      } else {
        throw const AudioException(
          '无效的音频源',
          code: 'AUDIO_INVALID_SOURCE',
        );
      }

      // 设置音量
      await _player.setVolume(noise.volume);

      // 循环播放
      await _player.setLoopMode(LoopMode.all);

      // 开始播放
      await _player.play();

      // 更新状态
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

  /// 暂停播放
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

  /// 恢复播放
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

  /// 停止播放
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

  /// 设置音量
  Future<void> setVolume(double volume) async {
    try {
      // 限制音量范围 0.0 - 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
      if (_currentNoise != null) {
        _currentNoise!.volume = clampedVolume;
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

  /// 切换播放/暂停
  Future<void> toggle(WhiteNoise noise) async {
    if (_currentNoise?.id == noise.id && _player.playing) {
      await pause();
    } else {
      await play(noise);
    }
  }

  /// 添加自定义白噪音
  void addCustomNoise(WhiteNoise noise) {
    customNoises.add(noise);
    Logger.i('添加自定义白噪音: ${noise.name}', tag: _tag);
  }

  /// 删除自定义白噪音
  Future<void> removeCustomNoise(String id) async {
    try {
      // 如果正在播放该噪音，先停止
      if (_currentNoise?.id == id) {
        await stop();
      }
      customNoises.removeWhere((noise) => noise.id == id);
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

  /// 释放资源
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
