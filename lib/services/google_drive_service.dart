import 'dart:convert';
import 'dart:io' as io;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import '../config/google_sheets_config.dart';

class GoogleDriveService {
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

  static Future<String?> uploadResumeFile({
    required final io.File resumeFile,
    required final String applicantName,
    required final String jobTitle,
    required final String companyName,
  }) async {
    try {
      // Parse credentials
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(_credentialsJson),
      );

      // Create authenticated client
      final client = await clientViaServiceAccount(
        credentials,
        [drive.DriveApi.driveScope],
      );

      // Create drive API instance
      final driveApi = drive.DriveApi(client);

      // Use the specific Google Drive folder you created
      const String folderId = GoogleSheetsConfig.driveFolderId;

      print('Using Google Drive folder: $folderId');

      // Create file name
      final fileName =
          '${applicantName.replaceAll(' ', '_')}_${companyName.replaceAll(' ', '_')}_${jobTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.${resumeFile.path.split('.').last}';

      // Upload file
      final bytes = await resumeFile.readAsBytes();

      final driveFile = drive.File(
        name: fileName,
        parents: [folderId],
      );

      final media = drive.Media(
        Stream.fromIterable([bytes]),
        bytes.length,
        contentType: 'application/octet-stream',
      );

      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
        supportsAllDrives: true,
      );

      // Close the client
      client.close();

      // Return the file ID and shareable link
      return 'https://drive.google.com/file/d/${uploadedFile.id}/view';
    } catch (e) {
      print('Error uploading to Google Drive: $e');
      return null;
    }
  }
}
