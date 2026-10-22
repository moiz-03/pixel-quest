import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/utils/validators.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // Email
  // ══════════════════════════════════════════════════════════════════════════
  group('Validators.email', () {
    test('rejects null', () {
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects empty string', () {
      expect(Validators.email(''), 'Email is required');
    });

    test('rejects whitespace-only string', () {
      expect(Validators.email('   '), 'Email is required');
    });

    test('rejects without @', () {
      expect(Validators.email('nope'), 'Enter a valid email');
    });

    test('rejects without domain', () {
      expect(Validators.email('nope@'), 'Enter a valid email');
    });

    test('rejects without local part', () {
      expect(Validators.email('@nope.com'), 'Enter a valid email');
    });

    test('rejects without TLD', () {
      expect(Validators.email('nope@com'), 'Enter a valid email');
    });

    test('rejects with spaces', () {
      expect(Validators.email('a b@ok.com'), 'Enter a valid email');
    });

    test('rejects consecutive dots', () {
      expect(Validators.email('a..b@x.com'), 'Enter a valid email');
    });

    test('rejects leading dot in local', () {
      expect(Validators.email('.user@x.com'), 'Enter a valid email');
    });

    test('rejects trailing dot in local', () {
      expect(Validators.email('user.@x.com'), 'Enter a valid email');
    });

    test('rejects local part over 64 chars', () {
      final longLocal = '${'a' * 65}@x.com';
      expect(Validators.email(longLocal), 'Enter a valid email');
    });

    test('rejects total over 254 chars', () {
      final long = '${'a' * 200}@${'b' * 60}.com';
      expect(Validators.email(long), 'Email is too long');
    });

    test('accepts simple valid email', () {
      expect(Validators.email('a@b.co'), isNull);
    });

    test('accepts dots in local', () {
      expect(Validators.email('user.name@example.com'), isNull);
    });

    test('accepts plus tag', () {
      expect(Validators.email('user+tag@sub.example.io'), isNull);
    });

    test('accepts hyphens in domain', () {
      expect(Validators.email('a@my-domain.com'), isNull);
    });

    test('accepts subdomains', () {
      expect(Validators.email('user@mail.corp.example.com'), isNull);
    });

    test('accepts underscores in local', () {
      expect(Validators.email('user_name@example.com'), isNull);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.email('  a@b.co  '), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Password (strict — for register)
  // ══════════════════════════════════════════════════════════════════════════
  group('Validators.password (strict)', () {
    test('rejects null', () {
      expect(Validators.password(null), 'Password is required');
    });

    test('rejects empty string', () {
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects under 8 characters', () {
      expect(Validators.password('Abc1!'), 'At least 8 characters');
    });

    test('rejects exactly 7 characters', () {
      expect(Validators.password('Abcdef1'), 'At least 8 characters');
    });

    test('rejects over 64 characters', () {
      final tooLong = 'Aa1!${'x' * 62}';
      expect(Validators.password(tooLong), 'Under 64 characters');
    });

    test('rejects leading space', () {
      expect(Validators.password(' Abcdef1!'), 'No leading or trailing spaces');
    });

    test('rejects trailing space', () {
      expect(Validators.password('Abcdef1! '), 'No leading or trailing spaces');
    });

    test('rejects without uppercase', () {
      expect(Validators.password('abcdef1!'), 'Add an uppercase letter (A-Z)');
    });

    test('rejects without lowercase', () {
      expect(Validators.password('ABCDEF1!'), 'Add a lowercase letter (a-z)');
    });

    test('rejects without digit', () {
      expect(Validators.password('Abcdefg!'), 'Add a number (0-9)');
    });

    test('rejects without special character', () {
      expect(
        Validators.password('Abcdefg1'),
        'Add a special character (!@#\$...)',
      );
    });

    test('accepts strong password', () {
      expect(Validators.password('Abcdef1!'), isNull);
    });

    test('accepts exactly 8 characters', () {
      expect(Validators.password('Abcdef1!'), isNull);
    });

    test('accepts exactly 64 characters', () {
      final exact = 'Aa1!${'x' * 60}';
      expect(Validators.password(exact), isNull);
    });

    test('accepts many special characters', () {
      expect(Validators.password(r'Ab1!@#$%^&*()'), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Login password (lenient)
  // ══════════════════════════════════════════════════════════════════════════
  group('Validators.loginPassword (lenient)', () {
    test('rejects null', () {
      expect(Validators.loginPassword(null), 'Password is required');
    });

    test('rejects empty string', () {
      expect(Validators.loginPassword(''), 'Password is required');
    });

    test('accepts short legacy password', () {
      expect(Validators.loginPassword('abc123'), isNull);
    });

    test('accepts weak legacy password', () {
      expect(Validators.loginPassword('password'), isNull);
    });

    test('accepts strong password', () {
      expect(Validators.loginPassword('Abcdef1!'), isNull);
    });

    test('accepts password with spaces', () {
      expect(Validators.loginPassword('  spaces  '), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Username
  // ══════════════════════════════════════════════════════════════════════════
  group('Validators.username', () {
    test('rejects null', () {
      expect(Validators.username(null), 'Username is required');
    });

    test('rejects empty', () {
      expect(Validators.username(''), 'Username is required');
    });

    test('rejects whitespace-only', () {
      expect(Validators.username('   '), 'Username is required');
    });

    test('rejects under 3 characters', () {
      expect(Validators.username('ab'), 'At least 3 characters');
    });

    test('rejects over 20 characters', () {
      final tooLong = 'a' * 21;
      expect(Validators.username(tooLong), 'Under 20 characters');
    });

    test('rejects space', () {
      expect(
        Validators.username('user name'),
        'Only letters, numbers, underscores',
      );
    });

    test('rejects hyphen', () {
      expect(
        Validators.username('user-name'),
        'Only letters, numbers, underscores',
      );
    });

    test('rejects dot', () {
      expect(
        Validators.username('user.name'),
        'Only letters, numbers, underscores',
      );
    });

    test('rejects punctuation', () {
      expect(
        Validators.username('user!'),
        'Only letters, numbers, underscores',
      );
    });

    test('accepts 3 characters', () {
      expect(Validators.username('abc'), isNull);
    });

    test('accepts letters + digits + underscore', () {
      expect(Validators.username('user_123'), isNull);
    });

    test('accepts exactly 20 characters', () {
      expect(Validators.username('a' * 20), isNull);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.username('  user_123  '), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Confirm password
  // ══════════════════════════════════════════════════════════════════════════
  group('Validators.confirmPassword', () {
    test('rejects null', () {
      expect(
        Validators.confirmPassword(null, 'abc123'),
        'Please confirm your password',
      );
    });

    test('rejects empty', () {
      expect(
        Validators.confirmPassword('', 'abc123'),
        'Please confirm your password',
      );
    });

    test('rejects mismatch', () {
      expect(
        Validators.confirmPassword('abc124', 'abc123'),
        'Passwords do not match',
      );
    });

    test('is case-sensitive', () {
      expect(
        Validators.confirmPassword('ABC123', 'abc123'),
        'Passwords do not match',
      );
    });

    test('accepts exact match', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Password strength (0–4)
  // ══════════════════════════════════════════════════════════════════════════
  group('Validators.passwordStrength', () {
    test('empty → 0', () {
      expect(Validators.passwordStrength(''), 0);
    });

    test('too short → 0', () {
      expect(Validators.passwordStrength('Ab1!'), 0);
    });

    test('8 chars, one class → 1', () {
      expect(Validators.passwordStrength('aaaaaaaa'), 1);
    });

    test('8 chars, two classes → 2', () {
      expect(Validators.passwordStrength('aaaaaaa1'), 2);
    });

    test('8 chars, three classes → 3', () {
      expect(Validators.passwordStrength('aaaaaaA1'), 3);
    });

    test('8 chars, four classes → 4', () {
      expect(Validators.passwordStrength('aaaaaaA1!'), 4);
    });

    test('long password with all classes → 4', () {
      expect(Validators.passwordStrength('MyStr0ng!Passw0rd'), 4);
    });

    group('Validators.gmail', () {
      test('rejects null', () {
        expect(Validators.gmail(null), 'Email is required');
      });

      test('rejects empty', () {
        expect(Validators.gmail(''), 'Email is required');
      });

      test('rejects non-gmail domain', () {
        expect(
          Validators.gmail('user@outlook.com'),
          'Please use a Gmail address',
        );
        expect(
          Validators.gmail('user@yahoo.com'),
          'Please use a Gmail address',
        );
        expect(
          Validators.gmail('user@example.com'),
          'Please use a Gmail address',
        );
        expect(
          Validators.gmail('user@icloud.com'),
          'Please use a Gmail address',
        );
      });

      test('accepts @gmail.com', () {
        expect(Validators.gmail('user@gmail.com'), isNull);
      });

      test('accepts @googlemail.com', () {
        expect(Validators.gmail('user@googlemail.com'), isNull);
      });

      test('is case-insensitive on domain', () {
        expect(Validators.gmail('USER@GMAIL.COM'), isNull);
        expect(Validators.gmail('User@Gmail.Com'), isNull);
        expect(Validators.gmail('user@GoogleMail.com'), isNull);
      });

      test('rejects malformed gmail', () {
        expect(Validators.gmail('nope@gmail'), 'Enter a valid email');
        expect(Validators.gmail('@gmail.com'), 'Enter a valid email');
        expect(Validators.gmail('a..b@gmail.com'), 'Enter a valid email');
      });

      test('rejects gmail with a subdomain', () {
        expect(
          Validators.gmail('user@mail.gmail.com'),
          'Please use a Gmail address',
        );
      });

      test('trims surrounding whitespace', () {
        expect(Validators.gmail('  user@gmail.com  '), isNull);
      });
    });
  });
}
