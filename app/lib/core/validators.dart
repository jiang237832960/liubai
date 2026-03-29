import 'exceptions.dart';

/// 输入验证工具类
class Validators {
  /// 验证专注时长
  /// 返回验证通过的消息，或抛出 ValidationException
  static void validateDuration(int minutes) {
    if (minutes < 1) {
      throw const ValidationException(
        '专注时长不能少于1分钟',
        code: 'DURATION_TOO_SHORT',
      );
    }
    if (minutes > 240) {
      throw const ValidationException(
        '专注时长不能超过4小时（240分钟）',
        code: 'DURATION_TOO_LONG',
      );
    }
  }

  /// 验证标签名称
  static void validateTagName(String name) {
    if (name.trim().isEmpty) {
      throw const ValidationException(
        '标签名称不能为空或仅包含空白字符',
        code: 'TAG_NAME_INVALID',
      );
    }
    if (name.trim().length > 20) {
      throw const ValidationException(
        '标签名称不能超过20个字符',
        code: 'TAG_NAME_TOO_LONG',
      );
    }
  }

  /// 限制音量值在有效范围内
  static double clampVolume(double volume) {
    return volume.clamp(0.0, 1.0);
  }

  /// 验证备注文本
  static void validateNote(String? note) {
    if (note != null && note.length > 500) {
      throw const ValidationException(
        '备注不能超过500个字符',
        code: 'NOTE_TOO_LONG',
      );
    }
  }

  /// 验证日期范围（用于手动补录）
  static void validateDateRange(DateTime date) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    // 移除时间部分，只比较日期
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    final thirtyDaysAgoOnly = DateTime(
      thirtyDaysAgo.year,
      thirtyDaysAgo.month,
      thirtyDaysAgo.day,
    );

    if (dateOnly.isAfter(nowOnly)) {
      throw const ValidationException(
        '不能选择未来的日期',
        code: 'DATE_IN_FUTURE',
      );
    }
    if (dateOnly.isBefore(thirtyDaysAgoOnly)) {
      throw const ValidationException(
        '只能补录最近30天的记录',
        code: 'DATE_TOO_OLD',
      );
    }
  }

  /// 验证文件路径（用于音频导入）
  static void validateAudioFilePath(String path) {
    final lowerPath = path.toLowerCase();
    final validExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg'];
    
    final hasValidExtension = validExtensions.any(
      (ext) => lowerPath.endsWith(ext),
    );
    
    if (!hasValidExtension) {
      throw ValidationException(
        '不支持的音频格式，请使用: ${validExtensions.join(", ")}',
        code: 'INVALID_AUDIO_FORMAT',
      );
    }

    // 检查文件大小（最大 50MB）
    // 注意：实际文件大小检查需要在文件操作中完成
  }

  /// 安全的字符串截断
  static String truncateString(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// 清理字符串（移除首尾空白，合并连续空白）
  static String sanitizeString(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 验证主题模式值
  static void validateThemeMode(String mode) {
    final validModes = ['light', 'dark', 'system'];
    if (!validModes.contains(mode)) {
      throw ValidationException(
        '无效的主题模式: $mode，可选值: ${validModes.join(", ")}',
        code: 'INVALID_THEME_MODE',
      );
    }
  }
}

/// 验证结果类
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorCode;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null,
        errorCode = null;

  const ValidationResult.invalid(this.errorMessage, this.errorCode)
      : isValid = false;
}
