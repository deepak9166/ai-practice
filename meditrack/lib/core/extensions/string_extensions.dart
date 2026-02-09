/// String Extensions
///
/// Utility extensions for String class to add common functionality
/// like validation, formatting, etc.
extension StringExtensions on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid password
  /// Must be at least 8 characters
  bool get isValidPassword {
    return length >= 8;
  }

  /// Check if string is not empty and not null
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  /// Capitalize first letter of string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }


  String get firstTwoLetter {
        List<String> parts = split(' ');
    String firstInitial = parts.isNotEmpty ? parts[0][0].toUpperCase() : '';
    String lastInitial = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    String initials = '$firstInitial$lastInitial';

    return initials;
  }
}
