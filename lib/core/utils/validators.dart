class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'Enter 6-digit OTP';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    if (double.tryParse(value) == null) return 'Enter a valid price';
    if (double.parse(value) <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.isEmpty) return 'Stock is required';
    if (int.tryParse(value) == null) return 'Enter a valid number';
    if (int.parse(value) < 0) return 'Stock cannot be negative';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.isEmpty) return 'Pincode is required';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) return 'Enter a valid 6-digit pincode';
    return null;
  }
}
