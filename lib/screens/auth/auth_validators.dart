// Form validators used by Login and Register.
// A validator returns an error message, or null when the value is fine.

String? validateRequired(String? v, String label) {
  if (v == null || v.trim().isEmpty) return '$label is required';
  return null;
}

String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Enter a valid email';
}

String? validatePhone(String? v) {
  if (v == null || v.trim().isEmpty) return 'Phone number is required';
  return RegExp(r'^\d{10}$').hasMatch(v.trim()) ? null : 'Enter a 10-digit phone number';
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Password is required';
  return v.length >= 6 ? null : 'Use at least 6 characters';
}
