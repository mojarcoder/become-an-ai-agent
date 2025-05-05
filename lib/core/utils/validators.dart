class Validators {
  // Required field validation
  static String? validateRequired(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
  
  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return null; // If it's empty, don't validate max length (let required validation handle it)
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    
    return null;
  }
  
  // URL validation
  static String? validateUrl(String? value, [String fieldName = 'URL']) {
    if (value == null || value.trim().isEmpty) {
      return null; // If it's empty, don't validate URL (let required validation handle it)
    }
    
    final urlPattern = RegExp(
      r'^(https?:\/\/)?' // protocol
      r'(([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
      r'((\d{1,3}\.){3}\d{1,3})' // OR ip (v4) address
      r'(\:\d+)?(\/[-a-z\d%_.~#+]*)*' // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    );
    
    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid $fieldName';
    }
    
    return null;
  }
  
  // Email validation
  static String? validateEmail(String? value, [String fieldName = 'Email']) {
    if (value == null || value.trim().isEmpty) {
      return null; // If it's empty, don't validate email (let required validation handle it)
    }
    
    final emailPattern = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    if (!emailPattern.hasMatch(value)) {
      return 'Please enter a valid $fieldName address';
    }
    
    return null;
  }
  
  // Date validation (past date)
  static String? validatePastDate(DateTime? value, [String fieldName = 'Date']) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return '$fieldName cannot be in the future';
    }
    
    return null;
  }
  
  // Date validation (future date)
  static String? validateFutureDate(DateTime? value, [String fieldName = 'Date']) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    final now = DateTime.now();
    if (value.isBefore(now)) {
      return '$fieldName cannot be in the past';
    }
    
    return null;
  }
} 