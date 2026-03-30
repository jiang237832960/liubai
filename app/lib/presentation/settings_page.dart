import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger.dart';
import '../core/theme.dart';
import '../data/database.dart';
import '../data/models.dart';
import '../data/models/scene_template.dart';
import '../providers/theme_provider.dart';
import '../services/template_service.dart';
import 'audio_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _templateService = TemplateService();
  UserSettings _settings = UserSettings();
  List<SceneTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final settings = await DatabaseHelper.instance.getSettings();
      final templates = await _templateService.getAllTemplates();
      if (mounted) {
        setState(() {
          _settings = settings;
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.e('加载设置失败', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    try {
      if (newSettings.themeMode != _settings.themeMode) {
        ref.read(themeProvider.notifier).setThemeMode(newSettings.themeMode);
      }
      
      await DatabaseHelper.instance.updateSettings(newSettings);
      if (mounted) {
        setState(() {
          _settings = newSettings;
        });
      }
    } catch (e) {
      Logger.e('更新设置失败', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新设置失败: $e')),
        );
      }
    }
  }

  String _getDefaultTemplateName() {
    if (_settings.defaultSceneTemplateId == null) {
      return '无';
    }
    try {
      final template = _templates.firstWhere((t) => t.id == _settings.defaultSceneTemplateId);
      return '${template.emoji} ${template.name}';
    } catch (e) {
      return '无';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      appBar: AppBar(
        title: const Text('设置', style: LiubaiTypography.h1),
        backgroundColor: LiubaiColors.liubaiWhite,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('留白设置'),
                _buildSettingCard(
                  title: '默认时长',
                  subtitle: '${_settings.defaultDuration}分钟',
                  onTap: _showDurationPicker,
                ),
                _buildSettingCard(
                  title: '默认场景',
                  subtitle: _getDefaultTemplateName(),
                  onTap: _showDefaultTemplatePicker,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('提醒设置'),
                _buildSwitchCard(
                  title: '声音提醒',
                  subtitle: '留白完成时播放提示音',
                  value: _settings.enableSound,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(enableSound: value));
                  },
                ),
                _buildSwitchCard(
                  title: '通知提醒',
                  subtitle: '留白完成时发送通知',
                  value: _settings.enableNotification,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(enableNotification: value));
                  },
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('留白音'),
                _buildSettingCard(
                  title: '留白音',
                  subtitle: '选择陪伴你的声音',
                  onTap: _navigateToAudio,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('外观设置'),
                _buildSettingCard(
                  title: '主题模式',
                  subtitle: _getThemeModeText(),
                  onTap: _showThemePicker,
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('关于'),
                _buildInfoCard(
                  title: '版本',
                  subtitle: '1.0.0',
                ),
                _buildInfoCard(
                  title: '留白',
                  subtitle: '东方美学极简专注工具',
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: LiubaiTypography.caption,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: LiubaiTypography.body),
        subtitle: Text(subtitle, style: LiubaiTypography.caption),
        trailing: const Icon(Icons.chevron_right, color: LiubaiColors.pineSmokeGray),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: LiubaiTypography.body),
        subtitle: Text(subtitle, style: LiubaiTypography.caption),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: LiubaiColors.inkBlack,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: LiubaiTypography.body),
        subtitle: Text(subtitle, style: LiubaiTypography.caption),
      ),
    );
  }

  String _getThemeModeText() {
    switch (_settings.themeMode) {
      case 'light':
        return '浅色模式';
      case 'dark':
        return '深色模式';
      case 'system':
      default:
        return '跟随系统';
    }
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择默认时长', style: LiubaiTypography.h2),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [5, 10, 15, 20, 25, 30, 45, 60].map((minutes) {
                  final isSelected = _settings.defaultDuration == minutes;
                  return GestureDetector(
                    onTap: () {
                      _updateSettings(_settings.copyWith(defaultDuration: minutes));
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? LiubaiColors.inkBlack : LiubaiColors.liubaiWhite,
                        border: Border.all(color: LiubaiColors.lightInkGray),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$minutes分钟',
                        style: TextStyle(
                          color: isSelected ? LiubaiColors.liubaiWhite : LiubaiColors.inkBlack,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDefaultTemplatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('选择默认场景', style: LiubaiTypography.h2),
              const SizedBox(height: 8),
              const Text('开始留白时自动选择的场景', style: LiubaiTypography.caption),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('无', style: LiubaiTypography.body),
                trailing: _settings.defaultSceneTemplateId == null
                    ? const Icon(Icons.check, color: LiubaiColors.inkBlack)
                    : null,
                onTap: () {
                  _updateSettings(_settings.copyWith(defaultSceneTemplateId: null));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ..._templates.map((template) {
                final isSelected = _settings.defaultSceneTemplateId == template.id;
                return ListTile(
                  leading: Text(template.emoji, style: const TextStyle(fontSize: 20)),
                  title: Text(template.name, style: LiubaiTypography.body),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: LiubaiColors.inkBlack)
                      : null,
                  onTap: () {
                    _updateSettings(_settings.copyWith(defaultSceneTemplateId: template.id));
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAudio() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AudioPage()),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择主题模式', style: LiubaiTypography.h2),
              const SizedBox(height: 24),
              _buildThemeOption('浅色模式', 'light'),
              _buildThemeOption('深色模式', 'dark'),
              _buildThemeOption('跟随系统', 'system'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String label, String mode) {
    final isSelected = _settings.themeMode == mode;
    return ListTile(
      title: Text(label, style: LiubaiTypography.body),
      trailing: isSelected
          ? const Icon(Icons.check, color: LiubaiColors.inkBlack)
          : null,
      onTap: () {
        _updateSettings(_settings.copyWith(themeMode: mode));
        Navigator.pop(context);
      },
    );
  }
}
