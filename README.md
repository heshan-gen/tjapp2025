# topjobs - Flutter Mobile App

A modern Flutter mobile application for job searching and career opportunities, designed for both Android and iOS platforms.

## Features

- **Job Search**: Browse and search for job opportunities
- **Job Details**: View comprehensive job information including requirements, salary, and company details
- **User Profile**: Manage personal information, skills, and job preferences
- **Save Jobs**: Bookmark interesting job postings
- **Apply to Jobs**: Submit applications directly through the app
- **Filter & Search**: Advanced filtering by location, job type, experience level, and more
- **Modern UI**: Clean, responsive design with Material Design 3
- **Dark Mode**: Support for both light and dark themes

## Screens

1. **Home Screen**: Welcome screen with featured jobs and quick search
2. **Job List Screen**: Browse all available jobs with filtering options
3. **Job Detail Screen**: Detailed view of individual job postings
4. **Profile Screen**: User profile management and settings

## Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **UI**: Material Design 3
- **Fonts**: Google Fonts (Roboto)
- **HTTP**: http package for API calls
- **Storage**: SharedPreferences for local data
- **Images**: Cached network images

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Xcode (for iOS development)
- Android SDK (for Android development)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd topjobs
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/               # State management
│   ├── job_provider.dart
│   └── user_provider.dart
├── screens/                 # UI screens
│   ├── home_screen.dart
│   ├── job_list_screen.dart
│   ├── job_detail_screen.dart
│   └── profile_screen.dart
└── theme/                   # App theming
    └── app_theme.dart
```

## Features in Detail

### Job Management
- Browse jobs with pagination
- Search by title, company, or skills
- Filter by location, type, and experience level
- Save jobs for later viewing
- Apply to jobs with one tap

### User Experience
- Intuitive navigation with bottom navigation bar
- Responsive design for different screen sizes
- Smooth animations and transitions
- Offline support for saved data

### Customization
- Theme switching (light/dark mode)
- Customizable user profile
- Skill management
- Notification preferences

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**topjobs** - Find your dream job today! 🚀
