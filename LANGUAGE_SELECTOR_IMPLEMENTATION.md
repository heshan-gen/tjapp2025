# Language Selector Implementation

## Overview
This document describes the language selector implementation that allows users to switch between English, Sinhala, and Tamil languages throughout the app.

## Files Created/Modified

### New Files Created:
1. **`lib/providers/language_provider.dart`**
   - Manages language state across the app
   - Supports 3 languages: English, Sinhala (සිංහල), Tamil (தமிழ்)
   - Persists language selection using SharedPreferences
   - Provides language codes, names, and tooltips

2. **`lib/widgets/language_selector_widget.dart`**
   - Reusable popup menu widget for language selection
   - Shows checkmark for currently selected language
   - Can be customized with icon color (useful for light/dark AppBars)
   - Uses Material Design popup menu with visual indicators

### Modified Files:

#### Core Files:
1. **`lib/main.dart`**
   - Added LanguageProvider to MultiProvider
   - Language state now available throughout the app

2. **`lib/data/rss_categories.dart`**
   - Added `getLocalizedTitle()` method to RssCategory class
   - Returns appropriate title based on selected language (englisht, sinhalat, or tamilt)

3. **`lib/widgets/category_selector.dart`**
   - Updated to use Consumer2<JobProvider, LanguageProvider>
   - Categories now display titles in the selected language
   - Real-time updates when language changes

#### Screen Files Updated:
Language selector is available in the following screens:
- ✅ `lib/screens/home_screen.dart` - **Language selector enabled**
- ✅ `lib/screens/category_job_screen.dart` - **Language selector enabled**
- ❌ `lib/screens/job_list_screen.dart` - No language selector
- ❌ `lib/screens/favorites_screen.dart` - No language selector
- ❌ `lib/screens/contact_us_screen.dart` - No language selector
- ❌ `lib/screens/job_detail_screen.dart` - No language selector
- ❌ `lib/screens/job_apply_screen.dart` - No language selector
- ❌ `lib/screens/applied_jobs_screen.dart` - No language selector
- ❌ `lib/screens/notification_settings_screen.dart` - No language selector
- ❌ `lib/screens/background_notification_settings_screen.dart` - No language selector

**Note:** The language selector is strategically placed only in the home screen and category screens where users interact with categorized content that has multilingual support.

## Features

### Language Provider
```dart
enum AppLanguage {
  english,
  sinhala,
  tamil,
}
```

**Methods:**
- `setLanguage(AppLanguage language)` - Changes the app language
- `toggleLanguage()` - Cycles through languages (EN → SI → TA → EN)
- `get currentLanguage` - Returns the current language
- `get languageCode` - Returns short code (EN, සිං, த)
- `get languageName` - Returns full name (English, සිංහල, தமிழ்)
- `get languageIcon` - Returns the language icon
- `get languageTooltip` - Returns helpful tooltip text

### Language Selector Widget
```dart
const LanguageSelectorWidget({
  super.key,
  this.iconColor,  // Optional: customize icon color
})
```

**Features:**
- Popup menu with all available languages
- Visual indicator (check circle) for current language
- Highlighted selection with theme color
- Smooth transitions between languages
- Customizable icon color for different AppBar styles

### Category Localization
The `RssCategory` class now has a method to get localized titles:
```dart
String getLocalizedTitle(AppLanguage language)
```

This automatically returns:
- `englisht` for English
- `sinhalat` for Sinhala
- `tamilt` for Tamil

## Usage

### In AppBar:
```dart
appBar: AppBar(
  title: Text('Title'),
  actions: [
    const LanguageSelectorWidget(),  // Default icon color
    // OR for white AppBars:
    const LanguageSelectorWidget(iconColor: Colors.white),
  ],
)
```

### Accessing Current Language:
```dart
Consumer<LanguageProvider>(
  builder: (context, languageProvider, child) {
    final currentLang = languageProvider.currentLanguage;
    // Use the language...
  },
)
```

### Getting Localized Category Title:
```dart
final category = RssCategories.categories[0];
final title = category.getLocalizedTitle(languageProvider.currentLanguage);
```

## How It Works

1. **User Opens App**
   - LanguageProvider loads saved preference from SharedPreferences
   - Default language is English if no preference exists

2. **User Taps Language Icon in AppBar**
   - Popup menu shows with all 3 languages
   - Current language is highlighted with checkmark
   - User selects desired language

3. **Language Changes**
   - LanguageProvider updates state
   - All Consumer widgets listening to LanguageProvider rebuild
   - Category titles update automatically
   - New language is saved to SharedPreferences

4. **Next App Launch**
   - Previously selected language is restored
   - User experience is consistent

## Benefits

1. **Accessibility**: Users can read content in their preferred language
2. **User Experience**: Seamless language switching without app restart
3. **Consistency**: Same language selector across all screens
4. **Persistence**: Language preference saved between app sessions
5. **Performance**: Efficient state management with Provider
6. **Maintainability**: Centralized language logic in LanguageProvider

## Language Support

Currently supported for:
- ✅ Category titles (Main feature)
- ✅ All screen AppBars have language selector

Future expansion possibilities:
- App-wide UI text localization
- Job descriptions localization
- Form labels localization
- Error messages localization

## Testing

To test the implementation:
1. Run the app
2. On the **home screen**, tap the language icon (globe icon) in the AppBar
3. Select a different language (English, සිංහල, or தமிழ்)
4. Observe category titles change immediately
5. Navigate to a category by tapping any category card
6. On the **category job screen**, you can also change the language using the AppBar selector
7. Navigate back to home - language preference is maintained
8. Restart the app - language preference should be maintained across sessions

## Notes

- The language selector appears **only on home screen and category job screens** for focused multilingual support
- The selector is positioned before the theme toggle button in the AppBar
- Icon color can be customized based on AppBar background (white for colored AppBars)
- Language changes are immediate and don't require app restart
- All 31 job categories have translations in all 3 languages
- The language setting persists across the entire app session
- Other screens don't show the language selector as they don't display localized category content

