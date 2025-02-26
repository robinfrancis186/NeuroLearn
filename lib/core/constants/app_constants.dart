class AppConstants {
  // Route Names
  static const String routeHome = '/';
  static const String routeDashboard = '/dashboard';
  static const String routeAuth = '/auth';
  static const String routeCollaboration = '/collaboration';
  static const String routeAssessment = '/assessment';
  static const String routeSettings = '/settings';
  
  // Asset Paths
  static const String imagePath = 'assets/images';
  static const String animationPath = 'assets/animations';
  static const String iconPath = 'assets/icons';
  static const String audioPath = 'assets/audio';
  
  // Storage Keys
  static const String storageKeyUser = 'user_data';
  static const String storageKeySettings = 'app_settings';
  static const String storageKeyProgress = 'learning_progress';
  static const String storageKeyStats = 'learning_statistics';
  
  // Learning Levels
  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];
  
  // Subjects
  static const Map<String, String> subjects = {
    'math': 'Mathematics',
    'language': 'Language',
    'memory': 'Memory',
    'life_skills': 'Life Skills'
  };
  
  // Error Messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please login again.';
  static const String errorPermission = 'Permission denied.';
  
  // Success Messages
  static const String successSave = 'Changes saved successfully.';
  static const String successUpload = 'Upload completed successfully.';
  static const String successSync = 'Data synchronized successfully.';
  
  // Timeouts
  static const int timeoutConnection = 30; // seconds
  static const int timeoutCache = 7; // days
  static const int timeoutSession = 30; // minutes
  
  // Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxParticipants = 5;
  static const int maxRetries = 3;
  
  // Date Formats
  static const String dateFormatDisplay = 'MMM dd, yyyy';
  static const String dateFormatStorage = 'yyyy-MM-dd';
  static const String timeFormatDisplay = 'hh:mm a';
  
  // Animation Durations
  static const int durationShort = 200; // milliseconds
  static const int durationMedium = 300; // milliseconds
  static const int durationLong = 500; // milliseconds
  
  // API Endpoints
  static const String endpointAuth = '/auth';
  static const String endpointUser = '/user';
  static const String endpointProgress = '/progress';
  static const String endpointStats = '/statistics';
} 