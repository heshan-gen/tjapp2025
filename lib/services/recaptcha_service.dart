import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../config/recaptcha_config.dart';

class RecaptchaService {
  static bool _isInitialized = false;
  static String? _lastToken;
  static DateTime? _lastTokenTime;
  static const Duration _tokenValidity = Duration(minutes: 2);

  /// Initialize reCAPTCHA v3
  static Future<void> initialize() async {
    try {
      _isInitialized = true;
      print('reCAPTCHA v3 initialized');
    } catch (e) {
      print('Failed to initialize reCAPTCHA v3: $e');
      rethrow;
    }
  }

  /// Get reCAPTCHA v3 token
  /// Note: This is a simplified implementation for demonstration
  /// In production, you should use a proper WebView or server-side approach
  static Future<String?> getToken() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Check if we have a valid cached token
      if (_lastToken != null &&
          _lastTokenTime != null &&
          DateTime.now().difference(_lastTokenTime!) < _tokenValidity) {
        return _lastToken;
      }

      // For now, generate a simulated token
      // In production, this should be done through a WebView or server-side
      final random = Random();
      final token = base64Encode(utf8.encode(
          '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000000)}'));

      _lastToken = token;
      _lastTokenTime = DateTime.now();

      return token;
    } catch (e) {
      print('Failed to get reCAPTCHA token: $e');
      return null;
    }
  }

  /// Verify reCAPTCHA token with your backend
  /// This should be called from your backend, not the client
  static Future<bool> verifyTokenWithBackend(final String token) async {
    try {
      // For now, we'll simulate a successful verification
      // In production, replace this with a call to your backend API
      // Example implementation:
      /*
      const String backendUrl = 'https://your-backend-api.com/api/contact';
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recaptchaToken': token,
          // Add other form data as needed
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      */

      // Temporary: Return true for testing (remove in production)
      return token.isNotEmpty;
    } catch (e) {
      print('Failed to verify reCAPTCHA token: $e');
      return false;
    }
  }

  /// Get the site key (for configuration purposes)
  static String get siteKey => RecaptchaConfig.siteKey;

  /// Get the action name
  static String get action => RecaptchaConfig.contactFormAction;

  /// Get the minimum score threshold
  static double get minScore => RecaptchaConfig.minScore;

  /// Clear cached token
  static void clearToken() {
    _lastToken = null;
    _lastTokenTime = null;
  }
}
