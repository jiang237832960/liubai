import 'package:flutter_test/flutter_test.dart';
import 'package:liubai/core/exceptions.dart';

void main() {
  group('LiubaiException Tests', () {
    test('should create exception with message only', () {
      const exception = LiubaiException('Test message');
      
      expect(exception.message, equals('Test message'));
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('should create exception with all fields', () {
      final originalError = Exception('Original');
      const exception = LiubaiException(
        'Test message',
        code: 'TEST_CODE',
        originalError: 'error',
      );
      
      expect(exception.message, equals('Test message'));
      expect(exception.code, equals('TEST_CODE'));
      expect(exception.originalError, equals('error'));
    });

    test('should format toString correctly', () {
      const exception = LiubaiException(
        'Test message',
        code: 'TEST_CODE',
      );
      
      expect(exception.toString(), equals('LiubaiException[TEST_CODE]: Test message'));
    });

    test('should format toString without code', () {
      const exception = LiubaiException('Test message');
      
      expect(exception.toString(), equals('LiubaiException[null]: Test message'));
    });
  });

  group('DatabaseException Tests', () {
    test('should create DatabaseException', () {
      const exception = DatabaseException(
        'Database error',
        code: 'DB_ERROR',
      );
      
      expect(exception.message, equals('Database error'));
      expect(exception.code, equals('DB_ERROR'));
      expect(exception, isA<LiubaiException>());
    });

    test('should format toString correctly', () {
      const exception = DatabaseException(
        'Connection failed',
        code: 'DB_CONN_ERROR',
      );
      
      expect(
        exception.toString(),
        equals('LiubaiException[DB_CONN_ERROR]: Connection failed'),
      );
    });
  });

  group('AudioException Tests', () {
    test('should create AudioException', () {
      const exception = AudioException(
        'Audio playback failed',
        code: 'AUDIO_PLAY_ERROR',
      );
      
      expect(exception.message, equals('Audio playback failed'));
      expect(exception.code, equals('AUDIO_PLAY_ERROR'));
      expect(exception, isA<LiubaiException>());
    });

    test('should handle original error', () {
      final original = Exception('File not found');
      const exception = AudioException(
        'Playback failed',
        code: 'AUDIO_FILE_ERROR',
        originalError: 'file_error',
      );
      
      expect(exception.originalError, equals('file_error'));
    });
  });

  group('FileException Tests', () {
    test('should create FileException', () {
      const exception = FileException(
        'File not found',
        code: 'FILE_NOT_FOUND',
      );
      
      expect(exception.message, equals('File not found'));
      expect(exception.code, equals('FILE_NOT_FOUND'));
      expect(exception, isA<LiubaiException>());
    });
  });

  group('ValidationException Tests', () {
    test('should create ValidationException', () {
      const exception = ValidationException(
        'Invalid input',
        code: 'VALIDATION_ERROR',
      );
      
      expect(exception.message, equals('Invalid input'));
      expect(exception.code, equals('VALIDATION_ERROR'));
      expect(exception, isA<LiubaiException>());
    });
  });

  group('NetworkException Tests', () {
    test('should create NetworkException', () {
      const exception = NetworkException(
        'Connection timeout',
        code: 'NETWORK_TIMEOUT',
      );
      
      expect(exception.message, equals('Connection timeout'));
      expect(exception.code, equals('NETWORK_TIMEOUT'));
      expect(exception, isA<LiubaiException>());
    });
  });

  group('Exception Hierarchy Tests', () {
    test('all exceptions should be LiubaiException subtype', () {
      const dbException = DatabaseException('DB error');
      const audioException = AudioException('Audio error');
      const fileException = FileException('File error');
      const validationException = ValidationException('Validation error');
      const networkException = NetworkException('Network error');

      expect(dbException, isA<LiubaiException>());
      expect(audioException, isA<LiubaiException>());
      expect(fileException, isA<LiubaiException>());
      expect(validationException, isA<LiubaiException>());
      expect(networkException, isA<LiubaiException>());
    });

    test('should catch all exceptions as LiubaiException', () {
      LiubaiException? caughtException;

      try {
        throw const DatabaseException('Test');
      } on LiubaiException catch (e) {
        caughtException = e;
      }

      expect(caughtException, isNotNull);
      expect(caughtException, isA<DatabaseException>());
    });
  });
}
