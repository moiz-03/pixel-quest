class Validators {
  Validators._();

  // ══════════════════════════════════════════════════════════════════════════
  // Email
  // ══════════════════════════════════════════════════════════════════════════

  /// HTML5-compatible email regex. Rejects obviously malformed input
  /// (consecutive dots, missing TLD, spaces, etc.) without being so strict
  /// that it rejects real addresses.
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+"
    r"@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (v.length > 254) return 'Email is too long';

    final atIndex = v.indexOf('@');
    if (atIndex < 1 || atIndex > 64) return 'Enter a valid email';

    // Reject consecutive dots anywhere
    if (v.contains('..')) return 'Enter a valid email';

    // Reject leading/trailing dot in the local part
    final local = v.substring(0, atIndex);
    if (local.startsWith('.') || local.endsWith('.')) {
      return 'Enter a valid email';
    }

    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Gmail (register-only variant)
  // ══════════════════════════════════════════════════════════════════════════

  /// Accepts only Gmail addresses (gmail.com and googlemail.com).
  /// Returns the standard email errors first, then enforces the Gmail domain.
  static String? gmail(String? value) {
    final baseError = email(value);
    if (baseError != null) return baseError;

    final v = value!.trim().toLowerCase();
    final domain = v.substring(v.indexOf('@') + 1);
    if (domain != 'gmail.com' && domain != 'googlemail.com') {
      return 'Please use a Gmail address';
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Password — STRICT (register / password reset)
  // ══════════════════════════════════════════════════════════════════════════

  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 64;

  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _hasSpecial = RegExp(r'[^A-Za-z0-9]');

  /// Strict password rules for registration. Returns the FIRST failed rule
  /// so the user isn't overwhelmed with a wall of errors.
  static String? password(String? value) {
    final v = value ?? '';

    if (v.isEmpty) return 'Password is required';
    if (v.length < passwordMinLength) {
      return 'At least $passwordMinLength characters';
    }
    if (v.length > passwordMaxLength) {
      return 'Under $passwordMaxLength characters';
    }
    if (v != v.trim()) {
      return 'No leading or trailing spaces';
    }
    if (!_hasUppercase.hasMatch(v)) {
      return 'Add an uppercase letter (A-Z)';
    }
    if (!_hasLowercase.hasMatch(v)) {
      return 'Add a lowercase letter (a-z)';
    }
    if (!_hasDigit.hasMatch(v)) {
      return 'Add a number (0-9)';
    }
    if (!_hasSpecial.hasMatch(v)) {
      return 'Add a special character (!@#\$...)';
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Password — LENIENT (login only)
  // ══════════════════════════════════════════════════════════════════════════

  /// Login-time validation. Only checks that something was entered.
  /// Rules are NOT enforced here — otherwise users with legacy passwords
  /// created before a rule change would be locked out of their own account.
  static String? loginPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Username
  // ══════════════════════════════════════════════════════════════════════════

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username is required';
    if (v.length < 3) return 'At least 3 characters';
    if (v.length > 20) return 'Under 20 characters';
    if (!_usernameRegex.hasMatch(v)) {
      return 'Only letters, numbers, underscores';
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Confirm password
  // ══════════════════════════════════════════════════════════════════════════

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Password strength (0–4)
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns 0–4:
  ///   0 = empty / too short
  ///   1 = weak       (1 of 4 character classes)
  ///   2 = fair       (2 of 4 character classes)
  ///   3 = strong     (3 of 4 character classes)
  ///   4 = excellent  (all 4 character classes)
  static int passwordStrength(String? value) {
    final v = value ?? '';
    if (v.length < passwordMinLength) return 0;

    int classes = 0;
    if (_hasUppercase.hasMatch(v)) classes++;
    if (_hasLowercase.hasMatch(v)) classes++;
    if (_hasDigit.hasMatch(v)) classes++;
    if (_hasSpecial.hasMatch(v)) classes++;
    return classes;
  }
}
