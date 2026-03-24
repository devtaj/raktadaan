class AppConstants {
  // App Info
  static const String appName = 'Raktadan';
  static const String appVersion = '1.0.0';
  
  // Blood Groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  
  // Request Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusOnTheWay = 'on_the_way';
  static const String statusDonating = 'donating';
  static const String statusFulfilled = 'fulfilled';
  static const String statusCancelled = 'cancelled';
  
  // Collection Names
  static const String donorsCollection = 'donors';
  static const String requestNotificationsCollection = 'request_notifications';
  static const String notificationsCollection = 'notifications';
  static const String savedRequestsCollection = 'saved_requests';
  static const String donationChatsCollection = 'donation_chats';
  static const String messagesCollection = 'messages';
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int minLocationLength = 3;
  static const int minIdLength = 5;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String genericError = 'An error occurred. Please try again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String permissionDenied = 'Permission denied. Please check your access rights.';
}