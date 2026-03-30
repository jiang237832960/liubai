import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/logger.dart';
import '../data/models/scene_template.dart';
import '../services/audio_service.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioService _audioService = AudioService();
  bool _isInitialized = false;
  SoundSource? _currentSource;

  @override
  void initState() {
    super.initState();
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    try {
      await _audioService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      Logger.e('音频服务初始化失败', tag: 'AudioPage', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('留白音', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              '选择一段声音，陪伴你的留白时光',
              style: LiubaiTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
          
          ...BuiltInAudioLibrary.sources.map((source) => _buildAudioCard(source)),
        ],
      ),
    );
  }

  Widget _buildAudioCard(SoundSource source) {
    final isPlaying = _audioService.currentSource?.id == source.id && 
                       _audioService.isPlaying;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(
          color: isPlaying ? LiubaiColors.inkBlack : LiubaiColors.lightInkGray,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(source.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(source.name, style: LiubaiTypography.body),
              ),
              IconButton(
                onPressed: () => _togglePlay(source),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: LiubaiColors.inkBlack,
                ),
              ),
            ],
          ),
          
          if (isPlaying)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.volume_down,
                    size: 16,
                    color: LiubaiColors.pineSmokeGray,
                  ),
                  Expanded(
                    child: Slider(
                      value: 1.0,
                      onChanged: (value) {},
                      activeColor: LiubaiColors.inkBlack,
                      inactiveColor: LiubaiColors.lightInkGray,
                    ),
                  ),
                  const Icon(
                    Icons.volume_up,
                    size: 16,
                    color: LiubaiColors.pineSmokeGray,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '100%',
                    style: LiubaiTypography.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _togglePlay(SoundSource source) async {
    try {
      if (_audioService.currentSource?.id == source.id && _audioService.isPlaying) {
        await _audioService.stop();
      } else {
        await _audioService.playSingle(source);
      }
      setState(() {
        _currentSource = _audioService.currentSource;
      });
    } catch (e) {
      Logger.e('音频播放失败', tag: 'AudioPage', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('音频播放失败，请检查音频文件')),
        );
      }
    }
  }
}
