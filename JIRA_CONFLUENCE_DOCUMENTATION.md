# TopJobs Mobile Application - Technical Documentation

## Table of Contents
1. [Application Overview](#application-overview)
2. [Architecture & Data Flow](#architecture--data-flow)
3. [Screen-by-Screen Documentation](#screen-by-screen-documentation)
4. [Data Retrieval Patterns](#data-retrieval-patterns)
5. [Web Scraping Implementation](#web-scraping-implementation)
6. [Key Features & Functionality](#key-features--functionality)
7. [Technical Implementation Details](#technical-implementation-details)

---

## Application Overview

The TopJobs Mobile Application is a Flutter-based job search platform that aggregates job listings from multiple RSS feeds provided by topjobs.lk. The application provides users with a comprehensive job search experience including category-based browsing, favorites management, detailed job views, and advanced filtering capabilities.

### Key Technologies
- **Framework**: Flutter (Dart)
- **State Management**: Provider Pattern
- **Data Sources**: RSS Feeds from topjobs.lk
- **Backend Services**: Firebase (View counts, ratings)
- **Web Scraping**: HTTP + HTML parsing
- **Local Storage**: SharedPreferences

---

## Architecture & Data Flow

### High-Level Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   RSS Feeds     │───▶│  JobProvider    │───▶│   UI Screens    │
│  (topjobs.lk)   │    │   (State Mgmt)  │    │   (Flutter)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Firebase      │
                       │ (View Counts,   │
                       │  Ratings)       │
                       └─────────────────┘
```

### Data Flow Process
1. **Initialization**: App loads RSS feeds from 30+ job categories
2. **Data Parsing**: XML parsing extracts job information
3. **State Management**: JobProvider manages all job data and filters
4. **UI Rendering**: Screens consume data through Provider pattern
5. **User Interactions**: Actions trigger state updates and navigation

---

## Screen-by-Screen Documentation

### 1. Home Screen (`home_screen.dart`)

**Purpose**: Main landing screen displaying recent jobs and search functionality

**Key Features**:
- Banner slider with promotional content
- Category selector for job browsing
- Search bar with real-time filtering
- Recent jobs list with expandable cards
- Theme toggle functionality

**Data Retrieval**:
- Loads all jobs from JobProvider
- Groups jobs by category and displays top 10 from each
- Implements search functionality with debouncing
- Manages expanded/collapsed state for job cards

**UI Components**:
- `BannerSlider`: Displays promotional banners
- `CategorySelector`: Grid of job categories
- Job cards with company logos, titles, and metadata
- Expandable job details with swipe gestures

### 2. Job List Screen (`job_list_screen.dart`)

**Purpose**: Comprehensive job listing with advanced filtering

**Key Features**:
- Full job list with pagination
- Advanced search and filtering
- Category selection modal
- Expandable job cards
- Swipe-to-favorite functionality

**Data Retrieval**:
- Consumes filtered jobs from JobProvider
- Implements search across title, company, location, and skills
- Location and experience level filtering
- Real-time filter application

**UI Components**:
- Search bar with clear functionality
- Filter bottom sheet with dropdowns and chips
- Category selection modal with grid layout
- Slidable job cards for favorite actions

### 3. Job Detail Screen (`job_detail_screen.dart`)

**Purpose**: Detailed view of individual job postings

**Key Features**:
- Complete job information display
- Web scraping for additional content
- Image gallery for job-related images
- Navigation between jobs (swipe gestures)
- Apply and share functionality

**Data Retrieval**:
- Displays job data from JobProvider
- **Web Scraping**: Fetches additional content from job URLs
- Company information via Google Custom Search API
- View count tracking and increment

**UI Components**:
- Job header with company logo and gradient background
- Navigation bar with job counter and previous/next buttons
- Expandable sections for description, requirements, skills
- Action buttons for apply and share
- Image viewer for scraped content

### 4. Category Job Screen (`category_job_screen.dart`)

**Purpose**: Job listings filtered by specific categories

**Key Features**:
- Category-specific job filtering
- Category switching functionality
- Same filtering capabilities as main job list
- Category-specific theming and icons

**Data Retrieval**:
- Loads jobs from specific RSS feed URL
- Applies same filtering logic as main job list
- Maintains separate state for category jobs

**UI Components**:
- Category header with job count
- Category switch modal
- Filtered job list with category-specific styling
- Same job card layout as main list

### 5. Favorites Screen (`favorites_screen.dart`)

**Purpose**: Management of user's favorite jobs

**Key Features**:
- Display saved favorite jobs
- Search within favorites
- Remove from favorites functionality
- Swipe-to-remove gestures

**Data Retrieval**:
- Retrieves favorite job IDs from SharedPreferences
- Filters main job list by favorite status
- Applies search within favorite jobs only

**UI Components**:
- Search bar for favorite jobs
- List of favorite job cards
- Empty state with helpful messaging
- Swipe actions for removal

---

## Data Retrieval Patterns

### 1. RSS Feed Processing

**Source**: 30+ RSS feeds from topjobs.lk
**Pattern**: Concurrent HTTP requests with XML parsing

```dart
// Concurrent fetching from multiple feeds
final List<Future<List<Job>>> futures = 
    _rssFeeds.map((feedUrl) => _fetchJobsFromRSS(feedUrl)).toList();
final List<List<Job>> results = await Future.wait(futures);
```

**Data Extraction**:
- Job title, company, location, salary
- Description, requirements, skills
- Posted date, closing date
- Company logo (publisher field)
- Remote work indicators

### 2. State Management Pattern

**Provider-based Architecture**:
- `JobProvider`: Central state management
- `ThemeProvider`: UI theme management
- `BannerProvider`: Promotional content

**Key Methods**:
- `loadJobs()`: Initial data loading
- `searchJobs()`: Real-time search with debouncing
- `filterByLocation()`: Location-based filtering
- `toggleFavorite()`: Favorites management

### 3. Data Persistence

**Local Storage**:
- SharedPreferences for favorites
- In-memory caching for job data
- View count tracking

**Firebase Integration**:
- View count synchronization
- Rating system
- Background data updates

---

## Web Scraping Implementation

### `_scrapedContent` Functionality

The `_scrapedContent` feature in the Job Detail Screen provides enhanced job information by scraping additional content from job posting URLs.

#### Implementation Details

**Service**: `WebScrapingService.fetchJobDescription()`

**Process Flow**:
1. **URL Generation**: Creates job-specific URL using job parameters
   ```dart
   String _generateApplicationUrl() {
     final Uri toLaunch = Uri(
       scheme: 'https',
       host: 'www.topjobs.lk',
       path: 'employer/JobAdvertismentServlet',
       queryParameters: {
         'ac': widget.job.applicantCode,
         'jc': widget.job.comments,
         'ec': widget.job.guid,
       },
     );
     return toLaunch.toString();
   }
   ```

2. **HTTP Request**: Makes request with proper headers
   ```dart
   final response = await http.get(
     Uri.parse(url),
     headers: {
       'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
       'Accept-Language': 'en-US,en;q=0.5',
       'Accept-Encoding': 'gzip, deflate',
       'Connection': 'keep-alive',
     },
   ).timeout(const Duration(seconds: 30));
   ```

3. **HTML Parsing**: Extracts content from specific elements
   ```dart
   final document = html_parser.parse(response.body);
   final remarkElement = document.getElementById('remark');
   
   if (remarkElement != null) {
     final String description = remarkElement.text.trim();
     final List<String> imageUrls = [];
     final imgElements = remarkElement.querySelectorAll('img');
     // Process images and return structured data
   }
   ```

4. **Data Structure**: Returns structured content
   ```dart
   class ScrapedJobContent {
     final String description;
     final List<String> imageUrls;
   }
   ```

#### UI Integration

**Loading States**:
- Shows loading animation during scraping
- Displays error message with retry option
- Graceful fallback to original content

**Content Display**:
- Additional job description text
- Image gallery with zoom functionality
- Proper error handling for failed requests

**Performance Optimizations**:
- 30-second timeout for requests
- Caching of scraped content
- Background processing to avoid UI blocking

---

## Key Features & Functionality

### 1. Search & Filtering
- **Real-time Search**: Debounced search across multiple fields
- **Multi-criteria Filtering**: Location, experience, job type
- **Category-based Filtering**: Industry-specific job browsing
- **Advanced Search**: Skills, company, and location matching

### 2. User Experience
- **Swipe Gestures**: Navigate between jobs, manage favorites
- **Expandable Cards**: Detailed job information on demand
- **Theme Support**: Light and dark mode
- **Responsive Design**: Optimized for various screen sizes

### 3. Data Management
- **Offline Support**: Cached job data
- **Favorites System**: Persistent user preferences
- **View Tracking**: Analytics for job popularity
- **Rating System**: User feedback on job postings

### 4. Performance Features
- **Lazy Loading**: Efficient memory usage
- **Image Caching**: Cached network images
- **Background Processing**: Non-blocking data operations
- **Optimized Rendering**: Efficient list building

---

## Technical Implementation Details

### State Management Architecture

**JobProvider** (Central State Manager):
```dart
class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  List<Job> _categoryJobs = [];
  Set<String> _favoriteJobIds = {};
  
  // Core methods
  Future<void> loadJobs();
  void searchJobs(String query);
  void filterByLocation(String location);
  void toggleFavorite(String jobComments);
}
```

### Data Models

**Job Model**:
```dart
class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String description;
  final String requirements;
  final String type;
  final String experience;
  final DateTime postedDate;
  final DateTime? closingDate;
  final String publisher; // Company logo
  final bool isRemote;
  final List<String> skills;
  final List<Color> gradientColors;
  final int viewCount;
  final double averageRating;
  final int totalRatings;
}
```

### Service Layer

**WebScrapingService**:
- HTTP client with proper headers
- HTML parsing with error handling
- Image URL extraction and processing
- Timeout and retry mechanisms

**CompanyService**:
- Google Custom Search API integration
- Company information retrieval
- Fallback mechanisms for API failures

**ViewCountService**:
- Firebase integration for analytics
- Batch updates for performance
- Local caching for offline support

### Error Handling

**Network Errors**:
- Graceful degradation for failed requests
- Retry mechanisms with exponential backoff
- User-friendly error messages

**Data Parsing**:
- Safe XML parsing with error recovery
- Validation of extracted data
- Fallback values for missing information

**UI Errors**:
- Loading states during data fetching
- Error boundaries for widget failures
- Consistent error messaging

---

## Conclusion

The TopJobs Mobile Application demonstrates a well-architected Flutter application with comprehensive job search functionality. The implementation showcases modern Flutter development practices including proper state management, efficient data handling, and user-centric design patterns. The web scraping functionality provides enhanced user experience by supplementing basic job data with rich content from job posting pages.

The application successfully handles large datasets from multiple RSS feeds while maintaining performance through optimized rendering, caching strategies, and background processing. The modular architecture allows for easy maintenance and future feature additions.

---

*Documentation Version: 1.0*  
*Last Updated: [Current Date]*  
*Application Version: Flutter 3.x*


