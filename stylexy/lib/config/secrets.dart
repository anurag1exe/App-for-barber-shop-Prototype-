/// Stylexy API Configuration
/// Replace placeholder values with your real API keys before production use.
/// DO NOT commit this file to version control with real keys.

class AppSecrets {
  // AI Hairstyle Preview API
  static const String aiApiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String aiApiKey = 'YOUR_API_KEY_HERE';
  static const String aiModel = 'gemini-3.6-flash';

  // Firebase (if migrating from local storage)
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';

  // App signing
  static const String appVersionName = '1.0.0';
  static const int appVersionCode = 1;
}
