class RecaptchaConfig {
  // reCAPTCHA v3 Configuration
  // Get these keys from: https://www.google.com/recaptcha/admin

  // Site Key - This is safe to expose in your app
  static const String siteKey = '6Lf7Zh8jAAAAAPFwsjg3gRJz6Z-szgasrMAL_GFw';

  // Secret Key - This should be kept secret and only used on your backend
  static const String secretKey = '6Lf7Zh8jAAAAAHP2FjcUeunJLhtraS3LJROxk7Nn';

  // Action name for the contact form
  static const String contactFormAction = 'contact_form_submit';

  // Minimum score threshold (0.0 to 1.0)
  // 0.0 = likely a bot, 1.0 = likely a human
  static const double minScore = 0.5;

  // reCAPTCHA API endpoints
  static const String verifyUrl =
      'https://www.google.com/recaptcha/api/siteverify';

  /// Instructions for setting up reCAPTCHA v3:
  ///
  /// 1. Go to https://www.google.com/recaptcha/admin
  /// 2. Create a new site or select an existing one
  /// 3. Choose reCAPTCHA v3
  /// 4. Add your domain(s) to the domain list
  /// 5. Copy the Site Key and Secret Key
  /// 6. Replace the placeholder values above with your actual keys
  ///
  /// For Flutter apps, you typically need to add these domains:
  /// - localhost (for development)
  /// - Your production domain
  /// - For mobile apps, you might need to add specific configurations
  ///
  /// Note: The Secret Key should never be exposed in your mobile app.
  /// It should only be used on your backend server for token verification.
}
