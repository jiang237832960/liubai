import 'dart:developer' as developer;

/// 日志级别
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}

/// 简单的日志工具类
class Logger {
  static const String _tag = '留白';
  static LogLevel _minLevel = LogLevel.debug;

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 详细日志
  static void v(String message, {String? tag}) {
    _log(LogLevel.verbose, message, tag: tag);
  }

  /// 调试日志
  static void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// 信息日志
  static void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// 警告日志
  static void w(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// 错误日志
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final prefix = '[$_tag${tag != null ? '/$tag' : ''}]';
    final levelStr = level.name.toUpperCase().substring(0, 1);
    final logMessage = '$prefix[$levelStr] $message';

    developer.log(
      logMessage,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
