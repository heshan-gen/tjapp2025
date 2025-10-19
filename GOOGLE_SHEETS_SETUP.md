# Google Sheets Integration Setup Guide

This guide will help you set up Google Sheets integration for saving job application data.

## Prerequisites

1. A Google Cloud Platform (GCP) account
2. A Google Sheets document where you want to store the job applications

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note down your project ID

## Step 2: Enable Google Sheets API

1. In the Google Cloud Console, go to "APIs & Services" > "Library"
2. Search for "Google Sheets API"
3. Click on it and enable the API

## Step 3: Create a Service Account

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "Service Account"
3. Fill in the service account details:
   - Name: `topjobs-sheets-service`
   - Description: `Service account for TopJobs app to write to Google Sheets`
4. Click "Create and Continue"
5. Skip the optional steps and click "Done"

## Step 4: Generate Service Account Key

1. In the Credentials page, find your service account
2. Click on the service account email
3. Go to the "Keys" tab
4. Click "Add Key" > "Create new key"
5. Choose "JSON" format
6. Download the JSON file and keep it secure

## Step 5: Create Google Sheets Document

1. Go to [Google Sheets](https://sheets.google.com/)
2. Create a new spreadsheet
3. Name it "Job Applications" (or any name you prefer)
4. Create a sheet named "Job Applications" (or update the config accordingly)
5. Add the following headers in the first row (A1 to L1):
   - A1: Timestamp
   - B1: Applicant Name
   - C1: Applicant Email
   - D1: Phone Number
   - E1: LinkedIn ID
   - F1: Job Title
   - G1: Company Name
   - H1: Job ID
   - I1: Job Location
   - J1: Resume File Name
   - K1: Cover Letter
   - L1: Application Source

## Step 6: Share the Spreadsheet

1. In your Google Sheets document, click "Share"
2. Add the service account email (from the JSON file) as an editor
3. The email will look like: `your-service-account@your-project.iam.gserviceaccount.com`

## Step 7: Update Configuration

1. Open `lib/config/google_sheets_config.dart`
2. Replace the placeholder values with your actual configuration:

```dart
class GoogleSheetsConfig {
  // Get this from your Google Sheets URL
  static const String spreadsheetId = 'YOUR_ACTUAL_SPREADSHEET_ID';
  static const String sheetName = 'Job Applications';
  static const String range = 'Job Applications!A:Z';
  
  // Get these from your downloaded JSON key file
  static const String projectId = 'your-actual-project-id';
  static const String privateKeyId = 'your-actual-private-key-id';
  static const String privateKey = '''-----BEGIN PRIVATE KEY-----
YOUR_ACTUAL_PRIVATE_KEY_HERE
-----END PRIVATE KEY-----''';
  static const String clientEmail = 'your-actual-service-account@your-project.iam.gserviceaccount.com';
  static const String clientId = 'your-actual-client-id';
  
  // Headers for the spreadsheet (first row)
  static const List<String> headers = [
    'Timestamp',
    'Applicant Name',
    'Applicant Email',
    'Phone Number',
    'LinkedIn ID',
    'Job Title',
    'Company Name',
    'Job ID',
    'Job Location',
    'Resume File Name',
    'Cover Letter',
    'Application Source',
  ];
}
```

## Step 8: Get Spreadsheet ID

The spreadsheet ID can be found in the URL of your Google Sheets document:
```
https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit#gid=0
```

## Step 9: Test the Integration

1. Run `flutter pub get` to install the new dependencies
2. Test the app by applying for a job
3. Check your Google Sheets document to see if the data is being saved

## Troubleshooting

### Common Issues:

1. **Authentication Error**: Make sure the service account has access to the spreadsheet
2. **Permission Denied**: Ensure the Google Sheets API is enabled in your GCP project
3. **Invalid Credentials**: Double-check that all the configuration values are correct
4. **Sheet Not Found**: Verify the spreadsheet ID and sheet name are correct

### Testing Connection:

You can test the Google Sheets connection by calling:
```dart
final isConnected = await GoogleSheetsService.testConnection();
print('Google Sheets connection: $isConnected');
```

## Security Notes

- Never commit the actual credentials to version control
- Consider using environment variables or secure storage for production
- Regularly rotate your service account keys
- Limit the service account permissions to only what's necessary

## Data Structure

Each job application will be saved as a new row with the following data:
- Timestamp (ISO 8601 format)
- Applicant details (name, email, phone, LinkedIn)
- Job details (title, company, ID, location)
- Application details (resume filename, cover letter)
- Source identifier ("Applied via TopJobs App")
