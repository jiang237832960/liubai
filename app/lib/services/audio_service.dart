import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../core/exceptions.dart';
import '../core/logger.dart';
import '../data/models/scene_template.dart';

class AudioMixer {
  static final AudioMixer _instance = AudioMixer._internal();
  factory AudioMixer() => _instance;
  AudioMixer._internal();

  static const String _tag = 'AudioMixer';

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _trackVolumes = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Set<String> get activeTrackIds => _players.keys.toSet();

  Future<void> initialize() async {
    if (_isInitialized) return;
    Logger.i('初始化音频混合器', tag: _tag);
    _isInitialized = true;
  }

  Future<void> addTrack(AudioTrack track) async {
    if (_players.containsKey(track.id)) {
      Logger.w('轨道已存在: ${track.id}', tag: _tag);
      return;
    }

    try {
      final player = AudioPlayer();
      
      String audioPath;
      if (track.soundSource.sourceType == SoundSourceType.builtIn) {
        audioPath = track.soundSource.assetPath;
        await player.setAsset(audioPath);
      } else if (track.soundSource.filePath != null) {
        audioPath = track.soundSource.filePath!;
        await player.setFilePath(audioPath);
      } else {
        throw AudioException(
          '无效的音频源: ${track.soundSource.id}',
          code: 'AUDIO_INVALID_SOURCE',
        );
      }

      await player.setLoopMode(LoopMode.all);
      await player.setVolume(track.volume);

      _players[track.id] = player;
      _trackVolumes[track.id] = track.volume;

      Logger.i('添加轨道成功: ${track.id} - ${track.name}', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('添加轨道失败: ${track.id}', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> removeTrack(String trackId) async {
    final player = _players.remove(trackId);
    if (player != null) {
      await player.dispose();
      _trackVolumes.remove(trackId);
      Logger.i('移除轨道: $trackId', tag: _tag);
    }
  }

  Future<void> setTrackVolume(String trackId, double volume) async {
    final player = _players[trackId];
    if (player != null) {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await player.setVolume(clampedVolume);
      _trackVolumes[trackId] = clampedVolume;
      Logger.d('设置轨道音量: $trackId -> $clampedVolume', tag: _tag);
    }
  }

  double getTrackVolume(String trackId) {
    return _trackVolumes[trackId] ?? 0.0;
  }

  Future<void> playTrack(String trackId) async {
    final player = _players[trackId];
    if (player != null) {
      await player.play();
      Logger.i('播放轨道: $trackId', tag: _tag);
    }
  }

  Future<void> pauseTrack(String trackId) async {
    final player = _players[trackId];
    if (player != null) {
      await player.pause();
      Logger.i('暂停轨道: $trackId', tag: _tag);
    }
  }

  Future<void> stopTrack(String trackId) async {
    final player = _players[trackId];
    if (player != null) {
      await player.stop();
      Logger.i('停止轨道: $trackId', tag: _tag);
    }
  }

  Future<void> playAll() async {
    for (final player in _players.values) {
      await player.play();
    }
    Logger.i('播放所有轨道: ${_players.length}个', tag: _tag);
  }

  Future<void> pauseAll() async {
    for (final player in _players.values) {
      await player.pause();
    }
    Logger.i('暂停所有轨道', tag: _tag);
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
    Logger.i('停止所有轨道', tag: _tag);
  }

  Future<void> fadeIn(String trackId, int durationMs) async {
    final player = _players[trackId];
    if (player == null) return;

    final targetVolume = _trackVolumes[trackId] ?? 1.0;
    await player.setVolume(0);
    await player.play();

    const steps = 20;
    final stepDuration = durationMs ~/ steps;
    final volumeStep = targetVolume / steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      await player.setVolume(volumeStep * i);
    }

    Logger.i('渐入完成: $trackId', tag: _tag);
  }

  Future<void> fadeOut(String trackId, int durationMs) async {
    final player = _players[trackId];
    if (player == null) return;

    final currentVolume = _trackVolumes[trackId] ?? 1.0;
    const steps = 20;
    final stepDuration = durationMs ~/ steps;
    final volumeStep = currentVolume / steps;

    for (int i = steps - 1; i >= 0; i--) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      await player.setVolume(volumeStep * i);
    }

    await player.pause();
    await player.setVolume(currentVolume);
    Logger.i('渐出完成: $trackId', tag: _tag);
  }

  bool isTrackPlaying(String trackId) {
    final player = _players[trackId];
    return player?.playing ?? false;
  }

  bool get isAnyPlaying {
    return _players.values.any((p) => p.playing);
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _trackVolumes.clear();
    _isInitialized = false;
    Logger.i('音频混合器已释放', tag: _tag);
  }
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const String _tag = 'Audio';

  final AudioMixer _mixer = AudioMixer();
  SoundSource? _currentSource;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  SoundSource? get currentSource => _currentSource;
  AudioMixer get mixer => _mixer;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _mixer.initialize();
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

  Future<void> playSingle(SoundSource source, {double volume = 1.0}) async {
    try {
      await stop();

      final track = AudioTrack(
        id: 'single_${source.id}',
        name: source.name,
        volume: volume,
        fadeInDuration: 500,
        fadeOutDuration: 500,
        soundSource: source,
      );

      await _mixer.addTrack(track);
      await _mixer.fadeIn(track.id, 500);
      _currentSource = source;

      Logger.i('播放音频: ${source.name}', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('播放失败: $source', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> playTracks(List<AudioTrack> tracks) async {
    try {
      await stop();

      for (final track in tracks) {
        await _mixer.addTrack(track);
      }

      for (final track in tracks) {
        if (track.fadeInDuration > 0) {
          await _mixer.fadeIn(track.id, track.fadeInDuration);
        } else {
          await _mixer.playTrack(track.id);
        }
      }

      if (tracks.isNotEmpty) {
        _currentSource = tracks.first.soundSource;
      }

      Logger.i('播放轨道组: ${tracks.length}个', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('播放轨道组失败', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _mixer.pauseAll();
      Logger.i('暂停播放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('暂停失败', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> resume() async {
    try {
      await _mixer.playAll();
      Logger.i('恢复播放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('恢复失败', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      for (final trackId in _mixer.activeTrackIds.toList()) {
        await _mixer.fadeOut(trackId, 300);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      await _mixer.stopAll();
      for (final trackId in _mixer.activeTrackIds.toList()) {
        await _mixer.removeTrack(trackId);
      }
      _currentSource = null;
      Logger.i('停止播放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('停止失败', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> setVolume(String trackId, double volume) async {
    try {
      await _mixer.setTrackVolume(trackId, volume);
    } catch (e, stackTrace) {
      Logger.e('设置音量失败: $trackId', tag: _tag, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  bool get isPlaying => _mixer.isAnyPlaying;

  Future<void> dispose() async {
    try {
      await _mixer.dispose();
      _isInitialized = false;
      _currentSource = null;
      Logger.i('音频服务已释放', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('释放音频服务失败', tag: _tag, error: e, stackTrace: stackTrace);
    }
  }
}
