class Validators {
  static final _email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final _password = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
  static final _digitsOnly = RegExp(r'^\d+$');

  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Name is required';
    if (s.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Email is required';
    if (!_email.hasMatch(s)) return 'Enter a valid email';
    return null;
  }

  static String? phone10(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Phone number is required';
    if (!_digitsOnly.hasMatch(s)) return 'Phone number must be numeric';
    if (s.length != 10) return 'Phone number must be 10 digits';
    return null;
  }

  static String? passwordStrong(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password is required';
    if (!_password.hasMatch(s)) {
      return 'Min 8 chars, 1 uppercase, 1 number, 1 special character';
    }
    return null;
  }
}
