# reCAPTCHA v3 Setup Instructions

This document provides step-by-step instructions for setting up reCAPTCHA v3 in the TopJobs Flutter app.

## Overview

reCAPTCHA v3 has been integrated into the "Send us a Message" form in the contact us page to protect against spam and abuse. Unlike reCAPTCHA v2, v3 runs in the background and provides a risk score without requiring user interaction.

**Note**: This implementation uses a custom approach with HTTP requests to Google's reCAPTCHA API, as there isn't a reliable Flutter-specific reCAPTCHA package available.

## Setup Steps

### 1. Get reCAPTCHA Keys

1. Go to [Google reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin)
2. Click "Create" to create a new site
3. Fill in the form:
   - **Label**: TopJobs Contact Form (or any descriptive name)
   - **reCAPTCHA type**: Select "reCAPTCHA v3"
   - **Domains**: Add your domains:
     - `localhost` (for development)
     - Your production domain (e.g., `topjobs.lk`)
     - For mobile apps, you may need to add specific configurations
4. Accept the Terms of Service
5. Click "Submit"

### 2. Configure Keys

After creating the site, you'll receive:
- **Site Key** (public key - safe to expose in your app)
- **Secret Key** (private key - keep this secret, use only on your backend)

### 3. Update Configuration

1. Open `lib/config/recaptcha_config.dart`
2. Replace the placeholder values:
   ```dart
   // Replace these with your actual keys
   static const String siteKey = 'YOUR_ACTUAL_SITE_KEY_HERE';
   static const String secretKey = 'YOUR_ACTUAL_SECRET_KEY_HERE';
   ```

### 4. Backend Verification (Recommended)

For production use, implement server-side verification:

1. Create an API endpoint on your backend
2. Send the reCAPTCHA token from the app to your backend
3. Verify the token with Google's API using your secret key
4. Check the score (0.0 = likely bot, 1.0 = likely human)
5. Only process the form if the score meets your threshold

Example backend verification (Node.js):
```javascript
const axios = require('axios');

async function verifyRecaptcha(token) {
  const response = await axios.post('https://www.google.com/recaptcha/api/siteverify', {
    secret: 'YOUR_SECRET_KEY',
    response: token
  });
  
  return response.data.success && response.data.score >= 0.5;
}
```

## How It Works

1. **Initialization**: reCAPTCHA v3 is initialized when the contact us screen loads
2. **Token Generation**: When the user submits the form, a reCAPTCHA token is generated
3. **Verification**: The token is verified (currently client-side, should be server-side in production)
4. **Form Submission**: If verification passes, the email is sent

## Configuration Options

You can customize the reCAPTCHA behavior in `lib/config/recaptcha_config.dart`:

- **Action Name**: `contact_form_submit` (identifies the form action)
- **Minimum Score**: `0.5` (adjust based on your needs)
- **Site Key**: Your public reCAPTCHA key
- **Secret Key**: Your private reCAPTCHA key

## Testing

1. **Development**: Use `localhost` in your reCAPTCHA domain list
2. **Production**: Add your actual domain to the reCAPTCHA configuration
3. **Mobile Testing**: Ensure your reCAPTCHA configuration supports mobile apps

## Troubleshooting

### Common Issues

1. **"reCAPTCHA verification failed"**: 
   - Check if your site key is correct
   - Ensure the domain is added to your reCAPTCHA configuration
   - Verify internet connectivity

2. **Token generation fails**:
   - Check if reCAPTCHA is properly initialized
   - Ensure the site key is valid
   - Check for any console errors

3. **Score too low**:
   - Adjust the minimum score threshold
   - Consider the user's behavior patterns
   - Test with different devices/browsers

### Debug Mode

To enable debug logging, add this to your `main.dart`:
```dart
import 'dart:developer' as developer;

// In your main function
developer.log('reCAPTCHA Debug Mode Enabled', name: 'RecaptchaService');
```

## Security Notes

- **Never expose your secret key** in the mobile app
- **Always verify tokens server-side** in production
- **Use HTTPS** for all reCAPTCHA communications
- **Monitor reCAPTCHA scores** to adjust thresholds as needed
- **Regularly rotate keys** for enhanced security

## Files Modified

- `pubspec.yaml` - Added flutter_recaptcha_v3 dependency
- `lib/services/recaptcha_service.dart` - reCAPTCHA service implementation
- `lib/config/recaptcha_config.dart` - Configuration management
- `lib/screens/contact_us_screen.dart` - Form integration
- `RECAPTCHA_SETUP.md` - This setup guide

## Support

For issues with reCAPTCHA integration:
1. Check the [reCAPTCHA documentation](https://developers.google.com/recaptcha/docs/v3)
2. Verify your configuration matches the requirements
3. Test with the reCAPTCHA test keys first
4. Contact the development team for assistance
