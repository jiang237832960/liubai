import 'package:flutter_test/flutter_test.dart';
import 'package:liubai/core/exceptions.dart';
import 'package:liubai/core/validators.dart';

void main() {
  group('Validators Tests', () {
    group('validateDuration', () {
      test('should accept valid duration (1-240 minutes)', () {
        expect(() => Validators.validateDuration(1), returnsNormally);
        expect(() => Validators.validateDuration(25), returnsNormally);
        expect(() => Validators.validateDuration(240), returnsNormally);
      });

      test('should throw for duration less than 1', () {
        expect(
          () => Validators.validateDuration(0),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateDuration(-1),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw for duration more than 240', () {
        expect(
          () => Validators.validateDuration(241),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateDuration(300),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateTagName', () {
      test('should accept valid tag name', () {
        expect(() => Validators.validateTagName('学习'), returnsNormally);
        expect(() => Validators.validateTagName('Work'), returnsNormally);
        expect(() => Validators.validateTagName('a'), returnsNormally);
      });

      test('should accept tag name with 20 characters', () {
        expect(
          () => Validators.validateTagName('一二三四五六七八九十一二三四五六七八九十'),
          returnsNormally,
        );
      });

      test('should throw for empty string', () {
        expect(
          () => Validators.validateTagName(''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw for whitespace only', () {
        expect(
          () => Validators.validateTagName('   '),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateTagName('\t\n'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw for tag name longer than 20 chars', () {
        expect(
          () => Validators.validateTagName('这是一个超过二十个字符的标签名称'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('clampVolume', () {
      test('should return same value for valid range (0.0-1.0)', () {
        expect(Validators.clampVolume(0.0), equals(0.0));
        expect(Validators.clampVolume(0.5), equals(0.5));
        expect(Validators.clampVolume(1.0), equals(1.0));
      });

      test('should clamp value below 0.0 to 0.0', () {
        expect(Validators.clampVolume(-0.1), equals(0.0));
        expect(Validators.clampVolume(-1.0), equals(0.0));
      });

      test('should clamp value above 1.0 to 1.0', () {
        expect(Validators.clampVolume(1.1), equals(1.0));
        expect(Validators.clampVolume(2.0), equals(1.0));
      });
    });

    group('validateNote', () {
      test('should accept null note', () {
        expect(() => Validators.validateNote(null), returnsNormally);
      });

      test('should accept note with 500 characters or less', () {
        expect(() => Validators.validateNote('Short note'), returnsNormally);
        expect(
          () => Validators.validateNote('a' * 500),
          returnsNormally,
        );
      });

      test('should throw for note longer than 500 characters', () {
        expect(
          () => Validators.validateNote('a' * 501),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateDateRange', () {
      test('should accept today', () {
        expect(
          () => Validators.validateDateRange(DateTime.now()),
          returnsNormally,
        );
      });

      test('should accept date within 30 days', () {
        final fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
        expect(
          () => Validators.validateDateRange(fifteenDaysAgo),
          returnsNormally,
        );
      });

      test('should accept date exactly 30 days ago', () {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        expect(
          () => Validators.validateDateRange(thirtyDaysAgo),
          returnsNormally,
        );
      });

      test('should throw for future date', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(
          () => Validators.validateDateRange(tomorrow),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw for date more than 30 days ago', () {
        final thirtyOneDaysAgo = DateTime.now().subtract(const Duration(days: 31));
        expect(
          () => Validators.validateDateRange(thirtyOneDaysAgo),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateAudioFilePath', () {
      test('should accept valid audio formats', () {
        expect(
          () => Validators.validateAudioFilePath('music.mp3'),
          returnsNormally,
        );
        expect(
          () => Validators.validateAudioFilePath('sound.wav'),
          returnsNormally,
        );
        expect(
          () => Validators.validateAudioFilePath('audio.m4a'),
          returnsNormally,
        );
        expect(
          () => Validators.validateAudioFilePath('track.aac'),
          returnsNormally,
        );
        expect(
          () => Validators.validateAudioFilePath('song.ogg'),
          returnsNormally,
        );
      });

      test('should accept uppercase extensions', () {
        expect(
          () => Validators.validateAudioFilePath('music.MP3'),
          returnsNormally,
        );
        expect(
          () => Validators.validateAudioFilePath('sound.WAV'),
          returnsNormally,
        );
      });

      test('should throw for invalid formats', () {
        expect(
          () => Validators.validateAudioFilePath('video.mp4'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateAudioFilePath('image.jpg'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateAudioFilePath('document.pdf'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateThemeMode', () {
      test('should accept valid theme modes', () {
        expect(() => Validators.validateThemeMode('light'), returnsNormally);
        expect(() => Validators.validateThemeMode('dark'), returnsNormally);
        expect(() => Validators.validateThemeMode('system'), returnsNormally);
      });

      test('should throw for invalid theme mode', () {
        expect(
          () => Validators.validateThemeMode('auto'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => Validators.validateThemeMode(''),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('truncateString', () {
      test('should return original string if within limit', () {
        expect(
          Validators.truncateString('Hello', 10),
          equals('Hello'),
        );
      });

      test('should truncate string exceeding limit', () {
        expect(
          Validators.truncateString('Hello World', 8),
          equals('Hello...'),
        );
      });

      test('should use custom suffix', () {
        expect(
          Validators.truncateString('Hello World', 8, suffix: '~~'),
          equals('Hello ~~'),
        );
      });
    });

    group('sanitizeString', () {
      test('should trim whitespace', () {
        expect(
          Validators.sanitizeString('  hello  '),
          equals('hello'),
        );
      });

      test('should collapse multiple spaces', () {
        expect(
          Validators.sanitizeString('hello    world'),
          equals('hello world'),
        );
      });

      test('should handle tabs and newlines', () {
        expect(
          Validators.sanitizeString('hello\t\tworld\n\ntest'),
          equals('hello world test'),
        );
      });
    });
  });

  group('ValidationResult Tests', () {
    test('valid result should have correct properties', () {
      const result = ValidationResult.valid();
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });

    test('invalid result should have correct properties', () {
      const result = ValidationResult.invalid('Error message', 'ERROR_CODE');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Error message'));
      expect(result.errorCode, equals('ERROR_CODE'));
    });
  });
}
