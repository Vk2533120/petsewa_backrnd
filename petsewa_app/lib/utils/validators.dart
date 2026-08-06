class Validators {
  // Email Validation: Checks format (e.g., user@domain.com)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    final email = value.trim();
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(email)) {
      return 'Please enter a valid email address (e.g. name@example.com)';
    }
    return null;
  }

  // Mobile Phone Number Validation: Checks 10-digit phone format
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile phone number';
    }
    final phone = value.trim().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final phoneRegExp = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegExp.hasMatch(phone)) {
      return 'Please enter a valid 10-digit mobile phone number (e.g. 9876543210)';
    }
    return null;
  }

  // Full Name Validation
  static String? validateName(String? value, {String label = 'full name'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $label';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
