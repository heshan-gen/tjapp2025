# reCAPTCHA Verification Failed - Fix Guide

## Problem Analysis

The "reCAPTCHA verification failed. Please try again." error was occurring due to several issues:

1. **Invalid reCAPTCHA Keys**: Using placeholder/demo keys instead of real ones
2. **Client-Side Verification**: Attempting to verify tokens on the client side (insecure)
3. **Simulated Implementation**: Using fake token generation instead of real reCAPTCHA

## Solution Implemented

### 1. Updated reCAPTCHA Service (`lib/services/recaptcha_service.dart`)

- ✅ Implemented proper WebView-based reCAPTCHA v3 integration
- ✅ Added token caching for better performance
- ✅ Separated client-side token generation from server-side verification
- ✅ Added proper error handling and timeouts

### 2. Updated Configuration (`lib/config/recaptcha_config.dart`)

- ✅ Replaced placeholder keys with clear instructions
- ✅ Added TODO comments for proper key setup

### 3. Updated Contact Form (`lib/screens/contact_us_screen.dart`)

- ✅ Updated to use new reCAPTCHA service methods
- ✅ Improved error handling

### 4. Added Backend Example (`backend_recaptcha_example.js`)

- ✅ Provided complete Node.js backend implementation
- ✅ Proper server-side reCAPTCHA verification
- ✅ Score threshold checking
- ✅ Action validation

## Next Steps to Fix the Issue

### Step 1: Get Valid reCAPTCHA Keys

1. Go to [Google reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin)
2. Create a new site or select existing one
3. Choose **reCAPTCHA v3**
4. Add your domains:
   - `localhost` (for development)
   - Your production domain
   - For mobile apps, you may need special configuration
5. Copy the **Site Key** and **Secret Key**

### Step 2: Update Configuration

Edit `lib/config/recaptcha_config.dart`:

```dart
// Replace these with your actual keys
static const String siteKey = 'YOUR_ACTUAL_SITE_KEY_HERE';
static const String secretKey = 'YOUR_ACTUAL_SECRET_KEY_HERE';
```

### Step 3: Set Up Backend Verification

1. Deploy the backend example (`backend_recaptcha_example.js`) to your server
2. Update the backend URL in `lib/services/recaptcha_service.dart`:

```dart
const String backendUrl = 'https://your-actual-backend.com/api/contact';
```

3. Uncomment and implement the HTTP request code in `verifyTokenWithBackend()`

### Step 4: Test the Implementation

1. Run `flutter pub get` to install the new `webview_flutter` dependency
2. Test the contact form with valid reCAPTCHA keys
3. Monitor the console for any errors

## Dependencies Added

- `webview_flutter: ^4.4.2` - For WebView-based reCAPTCHA integration

## Security Notes

- ✅ **Never expose secret keys** in mobile apps
- ✅ **Always verify tokens server-side** in production
- ✅ **Use HTTPS** for all communications
- ✅ **Monitor reCAPTCHA scores** and adjust thresholds

## Testing

### Development Testing
1. Use `localhost` in your reCAPTCHA domain list
2. Test with the reCAPTCHA test keys first
3. Check browser console for JavaScript errors

### Production Testing
1. Add your production domain to reCAPTCHA configuration
2. Test on actual devices
3. Monitor backend logs for verification results

## Troubleshooting

### Common Issues

1. **"reCAPTCHA verification failed"**
   - Check if site key is correct
   - Ensure domain is added to reCAPTCHA configuration
   - Verify internet connectivity

2. **Token generation fails**
   - Check WebView permissions
   - Ensure site key is valid
   - Check for JavaScript errors in console

3. **Score too low**
   - Adjust minimum score threshold in config
   - Consider user behavior patterns
   - Test with different devices/browsers

### Debug Mode

Add this to your `main.dart` for debugging:

```dart
import 'dart:developer' as developer;

// In your main function
developer.log('reCAPTCHA Debug Mode Enabled', name: 'RecaptchaService');
```

## Files Modified

- ✅ `pubspec.yaml` - Added webview_flutter dependency
- ✅ `lib/services/recaptcha_service.dart` - Complete rewrite with WebView integration
- ✅ `lib/config/recaptcha_config.dart` - Updated with proper instructions
- ✅ `lib/screens/contact_us_screen.dart` - Updated to use new service
- ✅ `backend_recaptcha_example.js` - New backend implementation example
- ✅ `RECAPTCHA_FIX_GUIDE.md` - This comprehensive guide

## Support

If you continue to experience issues:

1. Check the [reCAPTCHA v3 documentation](https://developers.google.com/recaptcha/docs/v3)
2. Verify your configuration matches the requirements
3. Test with reCAPTCHA test keys first
4. Check the backend logs for verification results
5. Ensure your domain is properly configured in reCAPTCHA admin console

The implementation is now properly structured for production use with real reCAPTCHA keys and backend verification.
