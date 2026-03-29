/// 应用基础异常
class LiubaiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const LiubaiException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'LiubaiException[$code]: $message';
}

/// 数据库异常
class DatabaseException extends LiubaiException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// 音频播放异常
class AudioException extends LiubaiException {
  const AudioException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// 文件操作异常
class FileException extends LiubaiException {
  const FileException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// 验证异常
class ValidationException extends LiubaiException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalError,
  });
}

/// 网络异常
class NetworkException extends LiubaiException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });
}
