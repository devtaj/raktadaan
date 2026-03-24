class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  static bool isValidBloodGroup(String bloodGroup) {
    const validGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return validGroups.contains(bloodGroup);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  static bool isValidId(String id) {
    return id.trim().isNotEmpty && id.length > 5;
  }

  static bool isValidLocation(String location) {
    return location.trim().length >= 3;
  }

  static String? validateBloodGroup(String? value) {
    if (value == null || value.isEmpty) return 'Blood group is required';
    if (!isValidBloodGroup(value)) return 'Select a valid blood group';
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) return 'Location is required';
    if (!isValidLocation(value)) return 'Enter a valid location';
    return null;
  }
}