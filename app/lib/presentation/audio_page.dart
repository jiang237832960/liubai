import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/theme.dart';
import '../core/logger.dart';
import '../services/audio_service.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioService _audioService = AudioService();
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    await _audioService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      appBar: AppBar(
        title: const Text('留白音', style: LiubaiTypography.h1),
        backgroundColor: LiubaiColors.liubaiWhite,
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
          
          ..._audioService.builtInNoises.map((noise) => _buildNoiseCard(noise)),
          
          if (_audioService.customNoises.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text('我的音频', style: LiubaiTypography.caption),
            ),
            ..._audioService.customNoises.map((noise) => _buildNoiseCard(noise)),
          ],
          
          const SizedBox(height: 24),
          
          Center(
            child: TextButton.icon(
              onPressed: _importAudio,
              icon: const Icon(Icons.add),
              label: const Text('导入音频'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoiseCard(WhiteNoise noise) {
    final isPlaying = _audioService.currentNoise?.id == noise.id && 
                      _audioService.isPlaying;
    final isCustom = !noise.isBuiltIn;
    
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
              Text(noise.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(noise.name, style: LiubaiTypography.body),
              ),
              if (isCustom)
                IconButton(
                  onPressed: () => _deleteCustomNoise(noise),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: LiubaiColors.pineSmokeGray,
                  ),
                ),
              IconButton(
                onPressed: () => _togglePlay(noise),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: LiubaiColors.inkBlack,
                ),
              ),
            ],
          ),
          
          if (isPlaying || _audioService.currentNoise?.id == noise.id)
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
                      value: noise.volume,
                      onChanged: (value) => _setVolume(noise, value),
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
                  Text(
                    '${(noise.volume * 100).toInt()}%',
                    style: LiubaiTypography.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _togglePlay(WhiteNoise noise) async {
    try {
      await _audioService.toggle(noise);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('音频播放失败，请检查音频文件')),
        );
      }
    }
  }

  Future<void> _setVolume(WhiteNoise noise, double volume) async {
    await _audioService.setVolume(volume);
    setState(() {});
  }

  Future<void> _importAudio() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (mounted) Navigator.pop(context);

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final fileName = file.name;
        final filePath = file.path!;

        final nameController = TextEditingController(text: fileName.split('.').first);
        
        final name = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('命名音频'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '音频名称',
                hintText: '输入音频名称',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, nameController.text),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        if (name != null && name.isNotEmpty) {
          final customNoise = WhiteNoise(
            id: _uuid.v4(),
            name: name,
            emoji: '🎵',
            type: WhiteNoiseType.custom,
            filePath: filePath,
            volume: 0.5,
          );

          _audioService.addCustomNoise(customNoise);
          setState(() {});

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已导入: $name')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteCustomNoise(WhiteNoise noise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${noise.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_audioService.currentNoise?.id == noise.id) {
        await _audioService.stop();
      }

      _audioService.removeCustomNoise(noise.id);
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除: ${noise.name}')),
        );
      }
    }
  }
}
