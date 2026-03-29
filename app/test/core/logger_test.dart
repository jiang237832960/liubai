import 'package:flutter_test/flutter_test.dart';
import 'package:liubai/core/logger.dart';

void main() {
  group('Logger Tests', () {
    test('should set minimum log level', () {
      // Initially debug level
      Logger.setMinLevel(LogLevel.debug);
      
      // Change to warning level
      Logger.setMinLevel(LogLevel.warning);
      
      // Should not throw
      expect(() => Logger.setMinLevel(LogLevel.error), returnsNormally);
    });

    test('should log verbose message', () {
      // Should not throw when logging
      expect(() => Logger.v('Verbose message'), returnsNormally);
      expect(() => Logger.v('Verbose with tag', tag: 'TestTag'), returnsNormally);
    });

    test('should log debug message', () {
      expect(() => Logger.d('Debug message'), returnsNormally);
      expect(() => Logger.d('Debug with tag', tag: 'TestTag'), returnsNormally);
    });

    test('should log info message', () {
      expect(() => Logger.i('Info message'), returnsNormally);
      expect(() => Logger.i('Info with tag', tag: 'TestTag'), returnsNormally);
    });

    test('should log warning message', () {
      expect(() => Logger.w('Warning message'), returnsNormally);
      expect(() => Logger.w('Warning with error', error: Exception('Test')), returnsNormally);
    });

    test('should log error message', () {
      expect(() => Logger.e('Error message'), returnsNormally);
      expect(
        () => Logger.e(
          'Error with details',
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('should filter logs based on minimum level', () {
      // Set minimum level to error
      Logger.setMinLevel(LogLevel.error);
      
      // These should not throw but will be filtered
      expect(() => Logger.v('Verbose'), returnsNormally);
      expect(() => Logger.d('Debug'), returnsNormally);
      expect(() => Logger.i('Info'), returnsNormally);
      expect(() => Logger.w('Warning'), returnsNormally);
      
      // This should be logged
      expect(() => Logger.e('Error'), returnsNormally);
      
      // Reset to debug level
      Logger.setMinLevel(LogLevel.debug);
    });
  });

  group('LogLevel Enum Tests', () {
    test('should have correct enum values', () {
      expect(LogLevel.verbose.index, equals(0));
      expect(LogLevel.debug.index, equals(1));
      expect(LogLevel.info.index, equals(2));
      expect(LogLevel.warning.index, equals(3));
      expect(LogLevel.error.index, equals(4));
    });

    test('should compare log levels correctly', () {
      expect(LogLevel.verbose.index < LogLevel.error.index, isTrue);
      expect(LogLevel.error.index > LogLevel.info.index, isTrue);
    });
  });
}
