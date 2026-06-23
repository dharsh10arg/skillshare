/// Application-wide constants
class AppConstants {
  // API Configuration
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetries = 3;

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // Booking
  static const List<int> supportedDurations = [30, 60, 120];
  static const List<String> expertiseLevels = ['beginner', 'intermediate', 'advanced', 'expert'];

  // UI
  static const int defaultPaginationLimit = 20;
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String themeKey = 'theme_mode';

  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String unauthorizedMessage = 'Unauthorized. Please login again.';
  static const String forbiddenMessage = 'Access denied. You do not have permission.';
  static const String notFoundMessage = 'Resource not found.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred.';
}

/// App feature flags for production control
class FeatureFlags {
  static const bool enableChatNotifications = true;
  static const bool enableVideoSessions = false;
  static const bool enableAdvancedSearch = true;
  static const bool enableUserRatings = true;
  static const bool enableOfflineMode = false;
  static const bool enableBeta = false;
}
