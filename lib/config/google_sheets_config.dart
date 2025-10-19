class GoogleSheetsConfig {
  // Replace these with your actual Google Sheets configuration
  static const String spreadsheetId =
      '1yIH-tcrqf_8qYDGP8HnTcvVXK7HKBx9oFJ8C4xw__x8';
  static const String sheetName = 'topjobs-app-ave';
  static const String range = 'topjobs-app-ave!A1:Z1000';

  // Google Drive shared drive for resume uploads
  static const String driveFolderId = '0AESc7XExHSGKUk9PVA';

  // Service Account Credentials
  // You need to create a service account in Google Cloud Console
  // and download the JSON key file, then replace the values below
  static const String projectId = 'tj2025v2-1760036018623';
  static const String privateKeyId = '8fd4c73dda44ccbfe8758827acb086566c06335d';
  static const String privateKey = '''-----BEGIN PRIVATE KEY-----
\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCepy/NxOLAx423\nWzvaR6IYmGV7O4S4t6WmhiJGUPt1w7thrzxI7nF3f5grrim42E7gpg3l73UbmMho\npqEzpCpyH/hcKkurVbyHdlnVPW05aB8cg/iLYC6MKE/PwrvSJDLP3yf5VV9Vzq5C\n5K3VczzogKqemWCIdcB2Kp5ZABU6Y93pHN93joHLPMxpuH5Zadxu593yVmdRDuct\nL97YKg+5kLiKhZgpDSlTTgaalPI9z1M1G/G3QbZFqHH3VQClnG4EBpMSbmuuEkSN\n5MEeJPwD3n70KvtE/DX8gLzoVHcffVRoAiEC9TQ8/LEtpqDnD19P3SY/S8DpTTKE\ngKc5BO1HAgMBAAECggEAKYaF9xxE44N3vtm02UWtkjV1PmOOMhDzXRo3p2Lz5leE\nWKWWqFosvcPaTviHeBe50Yf1FE1wP/hl4CpZABzEdVmT1n/FjYNj1KrwCWXKDGAJ\n4JtUNxrGJC468Zy9L1wFJq54loS3bsyphN24+Cjw9MQUpG1tvFnhtawjBRWF+OGY\nSDDPQLxxrUzKbjxWDRwpL5HUFWOLitU+OWGbcEdVSagtNBBEnk5cmrY2QrvlI/z2\nIEF9KICAG2QrU4wV3bkbv8YoEGk9nYrcNWTpStC5g7if0vbrTDDlISCDOvcfUzK0\njskx30U3/qnsRQPre8wgDbodNl3H2PvNi1qTOlMO2QKBgQDKk/d1yzJh8PRJRU7t\nHwZC/Lm1V9iEHPW1mthTjQya+OPJsCYqvU6CTH+eJ04C33Dm9MmYEs8T2kQWd+dS\nZTWwT0Y4EOydhz3R+5/csaiJYXnyU+Xp00D+jQvGz/AzbbDMp9LhvxHh71Aij9mt\nwY62KVK6aYXM6p8ZzT7c8Wz+/wKBgQDIfdmk5hVNte+ojIxs9qFwuOXVk+DjKRpC\nhgZQqnnOIg47iWj9tKYrvN4jbWMg43ARoQr4OcSnzwdHvC2c6aQBN4KQlvl5ONf1\nWsl/T1EYjbDmcfqq8bHiXEMtP1xQIuxFG4BMIVhI8LiBOv4zANrbSF7+O6Uhw1UP\nI8SivWZZuQKBgQCe9dD+q74TQKJQRISUaP3e3rVS6WXK9XaRVLpfhZTYnmkQQJsS\neo36jNCvZ6Q9eNv9PyRZopi/uUwoXVo1O5oPiYVORWmGizMlbM+avAXGF6k7UD5f\nZxffJwqQrWaM1Iwha6d84RPFOKanGD31rKaxpmd2Q4tsqsbB1l53vTKMPQKBgFmm\ndMDYpWQHW6/5kP1UVyIpe5RCOMg64+QlPAOsByVWcxjKO+lecwORw58B1dap/L3V\nTitq4XXMDExWZ+sHSm/E25w99jXvZhnvS7Siyfd5vEV/aAAybUFz0hIUh/nJc+7+\n+iKQsoKDKW2X7Hzv/+0X8moqT4/GYW2Qp+fBW1f5AoGBAKdhWRMwANpF5Pq2XuPX\nuw771ncMPH0xTaWRng4fdOwZ0R4KUHymygPRu4H7B3Hhul4GWyPMvKrEKs74fncp\ne3zdtkIRJpzH5/xq1eFJc513odoGKcDvgrh7KBfKFhUjk/usOFsApRBHeBKRRE5/\nOeBde514KZSxouw/uKKVbcYz\n
-----END PRIVATE KEY-----''';
  static const String clientEmail =
      'topjobs-app-ave@tj2025v2-1760036018623.iam.gserviceaccount.com';
  static const String clientId = '108375564890952013300';

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
    'Resume File Path',
    'Resume Drive Link',
    'Cover Letter',
    'Company Email',
    'Application Source',
  ];
}
