import 'dart:convert';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import '../config/google_sheets_config.dart';

class GoogleSheetsService {
  static String get _credentialsJson => '''
  {
    "type": "service_account",
    "project_id": "${GoogleSheetsConfig.projectId}",
    "private_key_id": "${GoogleSheetsConfig.privateKeyId}",
    "private_key": "${GoogleSheetsConfig.privateKey.replaceAll('\n', r'\n')}",
    "client_email": "${GoogleSheetsConfig.clientEmail}",
    "client_id": "${GoogleSheetsConfig.clientId}",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/${GoogleSheetsConfig.clientEmail.replaceAll('@', '%40')}"
  }
  ''';

  static Future<bool> saveJobApplication({
    required final String applicantName,
    required final String applicantEmail,
    required final String applicantPhone,
    required final String linkedinId,
    required final String coverLetter,
    required final String jobTitle,
    required final String companyName,
    required final String jobId,
    required final String jobLocation,
    required final String resumeFileName,
    required final String resumeFilePath,
    required final String resumeDriveLink,
    required final String companyEmail,
  }) async {
    try {
      // Parse credentials
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(_credentialsJson),
      );

      // Create authenticated client
      final client = await clientViaServiceAccount(
        credentials,
        [SheetsApi.spreadsheetsScope],
      );

      // Create sheets API instance
      final sheets = SheetsApi(client);

      // Get current timestamp
      final timestamp = DateTime.now().toIso8601String();

      // Prepare the row data
      final rowData = [
        timestamp, // A - Timestamp
        applicantName, // B - Applicant Name
        applicantEmail, // C - Applicant Email
        applicantPhone, // D - Phone Number
        linkedinId, // E - LinkedIn ID
        jobTitle, // F - Job Title
        companyName, // G - Company Name
        jobId, // H - Job ID
        jobLocation, // I - Job Location
        resumeFileName, // J - Resume File Name
        resumeFilePath, // K - Resume File Path
        resumeDriveLink, // L - Resume Drive Link
        coverLetter, // M - Cover Letter
        companyEmail, // N - Company Email
        'Applied via topjobs App', // O - Application Source
      ];

      // Create value range
      final valueRange = ValueRange(
        values: [rowData],
      );

      // Append the data to the sheet
      await sheets.spreadsheets.values.append(
        valueRange,
        GoogleSheetsConfig.spreadsheetId,
        'A:Z',
        valueInputOption: 'RAW',
      );

      // Close the client
      client.close();

      return true;
    } catch (e) {
      print('Error saving to Google Sheets: $e');
      return false;
    }
  }

  // Method to test the connection
  static Future<bool> testConnection() async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(_credentialsJson),
      );

      final client = await clientViaServiceAccount(
        credentials,
        [SheetsApi.spreadsheetsScope],
      );

      final sheets = SheetsApi(client);

      // Try to read a small range to test connection
      await sheets.spreadsheets.values.get(
        GoogleSheetsConfig.spreadsheetId,
        'A1:A1',
      );

      client.close();
      return true;
    } catch (e) {
      print('Google Sheets connection test failed: $e');
      return false;
    }
  }
}
