import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

class EmailService {
  // Email configuration - Replace with your actual SMTP settings
  static const String _smtpServer = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username =
      'heshan@genesiis.com'; // Replace with your Gmail address
  static const String _password =
      'ygot jgms xwvh cras'; // Replace with your Gmail App Password
  static const String _recipientEmail = 'heshan@genesiis.com';

  /// Send job application email
  static Future<EmailResult> sendJobApplication({
    required final String applicantName,
    required final String applicantEmail,
    required final String applicantPhone,
    required final String linkedinId,
    required final String coverLetter,
    required final String jobTitle,
    required final String companyName,
    required final String jobId,
    required final String jobLocation,
    required final String? resumeFileName,
    required final File? resumeFile,
  }) async {
    try {
      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        _smtpServer,
        port: _smtpPort,
        username: _username,
        password: _password,
        allowInsecure: false,
        ssl: false,
      );

      // Create email message
      final emailMessage = Message()
        ..from = const Address(
            _username, 'topjobs Job Application - Mobile Application')
        ..recipients.add(_recipientEmail)
        ..subject =
            '📋 New Job Application: $jobTitle at $companyName - $applicantName'
        ..html = _buildJobApplicationHtml(
          applicantName,
          applicantEmail,
          applicantPhone,
          linkedinId,
          coverLetter,
          jobTitle,
          companyName,
          jobId,
          jobLocation,
          resumeFileName,
        )
        ..text = _buildJobApplicationText(
          applicantName,
          applicantEmail,
          applicantPhone,
          linkedinId,
          coverLetter,
          jobTitle,
          companyName,
          jobId,
          jobLocation,
          resumeFileName,
        );

      // Add resume file as attachment if available
      if (resumeFile != null && resumeFile.existsSync()) {
        final attachment = FileAttachment(resumeFile);
        if (resumeFileName != null) {
          attachment.fileName = resumeFileName;
        }
        emailMessage.attachments = [attachment];
      }

      // Send email
      final sendReport = await send(emailMessage, smtpServer);

      return EmailResult(
        success: true,
        message: 'Job application sent successfully!',
        report: sendReport.toString(),
      );
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Failed to send job application: ${e.toString()}',
        report: null,
      );
    }
  }

  /// Send contact form email
  static Future<EmailResult> sendContactForm({
    required final String name,
    required final String email,
    required final String subject,
    required final String message,
  }) async {
    try {
      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        _smtpServer,
        port: _smtpPort,
        username: _username,
        password: _password,
        allowInsecure: false,
        ssl: false,
      );

      // Create email message
      final emailMessage = Message()
        ..from = const Address(
            _username, 'topjobs Contact Form - Mobile Application')
        ..recipients.add(_recipientEmail)
        ..subject = '🔔 New Inquiry: $subject - topjobs Platform'
        ..html = _buildEmailHtml(name, email, subject, message)
        ..text = _buildEmailText(name, email, subject, message);

      // Send email
      final sendReport = await send(emailMessage, smtpServer);

      return EmailResult(
        success: true,
        message: 'Email sent successfully!',
        report: sendReport.toString(),
      );
    } catch (e) {
      return EmailResult(
        success: false,
        message: 'Failed to send email: ${e.toString()}',
        report: null,
      );
    }
  }

  /// Build HTML email content for job applications
  static String _buildJobApplicationHtml(
    final String applicantName,
    final String applicantEmail,
    final String applicantPhone,
    final String linkedinId,
    final String coverLetter,
    final String jobTitle,
    final String companyName,
    final String jobId,
    final String jobLocation,
    final String? resumeFileName,
  ) {
    return '''
    <html>
      <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f8f9fa;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
          <!-- Header -->
          <div style="text-align: center; padding: 20px 0; border-bottom: 3px solid #37B307; margin-bottom: 30px;">
            <div style="margin-bottom: 20px;">
              <img src="https://www.topjobs.lk/images/public/tj.jpg" alt="topjobs Logo" style="max-width: 120px; height: auto; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            </div>
            <h1 style="color: #37B307; margin: 0; font-size: 20px; font-weight: 600;">
              📋 New Job Application Received
            </h1>
            <p style="color: #666; margin: 10px 0 0 0; font-size: 16px;">
              Job Application Submission - topjobs mobile application Platform
            </p>
          </div>
          
          <!-- Job Information Section -->
          <div style="background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 25px; border-radius: 12px; margin: 25px 0; border-left: 5px solid #37B307;">
            <h2 style="margin: 0 0 20px 0; color: #2c3e50; font-size: 20px; font-weight: 600;">
              💼 Job Information
            </h2>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057; width: 100px;">Position:</td>
                <td style="padding: 8px 0; color: #212529; font-weight: 500;">$jobTitle</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Company:</td>
                <td style="padding: 8px 0; color: #212529;">$companyName</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Job ID:</td>
                <td style="padding: 8px 0; color: #212529;">$jobId</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Location:</td>
                <td style="padding: 8px 0; color: #212529;">$jobLocation</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Date:</td>
                <td style="padding: 8px 0; color: #212529;">${DateTime.now().toString().split(' ')[0]}</td>
              </tr>
            </table>
          </div>

          <!-- Applicant Information Section -->
          <div style="background: linear-gradient(135deg, #e8f5e8 0%, #d4edda 100%); padding: 25px; border-radius: 12px; margin: 25px 0; border-left: 5px solid #28a745;">
            <h2 style="margin: 0 0 20px 0; color: #2c3e50; font-size: 20px; font-weight: 600;">
              👤 Applicant Information
            </h2>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057; width: 100px;">Name:</td>
                <td style="padding: 8px 0; color: #212529; font-weight: 500;">$applicantName</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Email:</td>
                <td style="padding: 8px 0; color: #212529;"><a href="mailto:$applicantEmail" style="color: #37B307; text-decoration: none;">$applicantEmail</a></td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Phone:</td>
                <td style="padding: 8px 0; color: #212529;"><a href="tel:$applicantPhone" style="color: #37B307; text-decoration: none;">$applicantPhone</a></td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">LinkedIn:</td>
                <td style="padding: 8px 0; color: #212529;">${linkedinId.isNotEmpty ? '<a href="https://linkedin.com/in/$linkedinId" style="color: #37B307; text-decoration: none;">linkedin.com/in/$linkedinId</a>' : 'Not provided'}</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Resume:</td>
                <td style="padding: 8px 0; color: #212529;">
                  ${resumeFileName != null ? '📎 $resumeFileName (attached)' : 'Not uploaded'}
                </td>
              </tr>
            </table>
          </div>
          
          <!-- Cover Letter Section -->
          <div style="background-color: #ffffff; padding: 25px; border: 1px solid #dee2e6; border-radius: 12px; margin: 25px 0; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);">
            <h2 style="margin: 0 0 20px 0; color: #2c3e50; font-size: 20px; font-weight: 600;">
              💬 Cover Letter
            </h2>
            <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #37B307;">
              <p style="margin: 0; white-space: pre-wrap; color: #212529; line-height: 1.7; font-size: 15px;">$coverLetter</p>
            </div>
          </div>
          
          <!-- Action Required Section -->
          <div style="background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%); padding: 20px; border-radius: 12px; margin: 25px 0; text-align: center;">
            <h3 style="margin: 0 0 15px 0; color: #856404; font-size: 18px;">
              ⚡ Action Required
            </h3>
            <p style="margin: 0; color: #6c5700; font-size: 14px; line-height: 1.5;">
              Please review this job application and respond to the candidate within 48 hours.
              ${resumeFileName != null ? '<br><br><strong>📎 Resume file is attached to this email.</strong>' : ''}
            </p>
          </div>
          
          <!-- Footer -->
          <div style="margin-top: 30px; padding: 20px; background-color: #f8f9fa; border-radius: 8px; text-align: center; border-top: 2px solid #e9ecef;">
            <p style="margin: 0 0 10px 0; font-size: 14px; color: #6c757d;">
              <strong>topjobs mobile application Platform</strong> - Professional Job Portal
            </p>
            <p style="margin: 0; font-size: 12px; color: #adb5bd;">
              This job application was submitted through our mobile application platform.
            </p>
            <p style="margin: 10px 0 0 0; font-size: 11px; color: #adb5bd;">
              Generated on ${DateTime.now().toString().split('.')[0]}
            </p>
          </div>
        </div>
      </body>
    </html>
    ''';
  }

  /// Build plain text email content for job applications
  static String _buildJobApplicationText(
    final String applicantName,
    final String applicantEmail,
    final String applicantPhone,
    final String linkedinId,
    final String coverLetter,
    final String jobTitle,
    final String companyName,
    final String jobId,
    final String jobLocation,
    final String? resumeFileName,
  ) {
    return '''
═══════════════════════════════════════════════════════════════
                    📋 NEW JOB APPLICATION RECEIVED
              Job Application Submission - topjobs Platform
                    Logo: https://www.topjobs.lk/images/public/tj.jpg
═══════════════════════════════════════════════════════════════

💼 JOB INFORMATION
───────────────────────────────────────────────────────────────
Position: $jobTitle
Company:  $companyName
Job ID:   $jobId
Location: $jobLocation
Date:     ${DateTime.now().toString().split(' ')[0]}

👤 APPLICANT INFORMATION
───────────────────────────────────────────────────────────────
Name:     $applicantName
Email:    $applicantEmail
Phone:    $applicantPhone
LinkedIn: ${linkedinId.isNotEmpty ? 'linkedin.com/in/$linkedinId' : 'Not provided'}
Resume:   ${resumeFileName != null ? '📎 $resumeFileName (attached)' : 'Not uploaded'}

💬 COVER LETTER
───────────────────────────────────────────────────────────────
$coverLetter

⚡ ACTION REQUIRED
───────────────────────────────────────────────────────────────
Please review this job application and respond to the candidate 
within 48 hours.
${resumeFileName != null ? '\n\n📎 Resume file is attached to this email.' : ''}

───────────────────────────────────────────────────────────────
topjobs Platform - Professional Job Portal
This job application was submitted through our mobile application platform.

Generated on: ${DateTime.now().toString().split('.')[0]}
═══════════════════════════════════════════════════════════════
    ''';
  }

  /// Build HTML email content
  static String _buildEmailHtml(final String name, final String email,
      final String subject, final String message) {
    return '''
    <html>
      <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f8f9fa;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
          <!-- Header -->
          <div style="text-align: center; padding: 20px 0; border-bottom: 3px solid #AF140C; margin-bottom: 30px;">
            <div style="margin-bottom: 20px;">
              <img src="https://www.topjobs.lk/images/public/tj.jpg" alt="topjobs Logo" style="max-width: 120px; height: auto; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            </div>
            <h1 style="color: #AF140C; margin: 0; font-size: 20px; font-weight: 600;">
              New Inquiry Received
            </h1>
            <p style="color: #666; margin: 10px 0 0 0; font-size: 16px;">
              Contact Form Submission - topjobs mobile application Platform
            </p>
          </div>
          
          <!-- Contact Information Section -->
          <div style="background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 25px; border-radius: 12px; margin: 25px 0; border-left: 5px solid #AF140C;">
            <h2 style="margin: 0 0 20px 0; color: #2c3e50; font-size: 20px; font-weight: 600;">
              👤 Contact Information
            </h2>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057; width: 80px;">Name:</td>
                <td style="padding: 8px 0; color: #212529;">$name</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Email:</td>
                <td style="padding: 8px 0; color: #212529;"><a href="mailto:$email" style="color: #AF140C; text-decoration: none;">$email</a></td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Subject:</td>
                <td style="padding: 8px 0; color: #212529; font-weight: 500;">$subject</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: 600; color: #495057;">Date:</td>
                <td style="padding: 8px 0; color: #212529;">${DateTime.now().toString().split(' ')[0]}</td>
              </tr>
            </table>
          </div>
          
          <!-- Message Section -->
          <div style="background-color: #ffffff; padding: 25px; border: 1px solid #dee2e6; border-radius: 12px; margin: 25px 0; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);">
            <h2 style="margin: 0 0 20px 0; color: #2c3e50; font-size: 20px; font-weight: 600;">
              💬 Message Content
            </h2>
            <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #28a745;">
              <p style="margin: 0; white-space: pre-wrap; color: #212529; line-height: 1.7; font-size: 15px;">$message</p>
            </div>
          </div>
          
          <!-- Action Required Section -->
          <div style="background: linear-gradient(135deg, #fdeaea 0%, #f5c6c6 100%); padding: 20px; border-radius: 12px; margin: 25px 0; text-align: center;">
            <h3 style="margin: 0 0 15px 0; color: #8B0E08; font-size: 18px;">
              ⚡ Action Required
            </h3>
            <p style="margin: 0; color: #6B0A06; font-size: 14px; line-height: 1.5;">
              Please respond to this inquiry within 24 hours to maintain our professional service standards.
            </p>
          </div>
          
          <!-- Footer -->
          <div style="margin-top: 30px; padding: 20px; background-color: #f8f9fa; border-radius: 8px; text-align: center; border-top: 2px solid #e9ecef;">
            <p style="margin: 0 0 10px 0; font-size: 14px; color: #6c757d;">
              <strong>topjobs mobile application Platform</strong> - Professional Job Portal
            </p>
            <p style="margin: 0; font-size: 12px; color: #adb5bd;">
              This inquiry was submitted through our mobile application contact form system.
            </p>
            <p style="margin: 10px 0 0 0; font-size: 11px; color: #adb5bd;">
              Generated on ${DateTime.now().toString().split('.')[0]}
            </p>
          </div>
        </div>
      </body>
    </html>
    ''';
  }

  /// Build plain text email content
  static String _buildEmailText(final String name, final String email,
      final String subject, final String message) {
    return '''
═══════════════════════════════════════════════════════════════
                    📧 NEW INQUIRY RECEIVED
              Contact Form Submission - topjobs Platform
                    Logo: https://www.topjobs.lk/images/public/tj.jpg
═══════════════════════════════════════════════════════════════

👤 CONTACT INFORMATION
───────────────────────────────────────────────────────────────
Name:    $name
Email:   $email
Subject: $subject
Date:    ${DateTime.now().toString().split(' ')[0]}

💬 MESSAGE CONTENT
───────────────────────────────────────────────────────────────
$message

⚡ ACTION REQUIRED
───────────────────────────────────────────────────────────────
Please respond to this inquiry within 24 hours to maintain our 
professional service standards.

───────────────────────────────────────────────────────────────
topjobs Platform - Professional Job Portal
This inquiry was submitted through our mobile application 
contact form system.

Generated on: ${DateTime.now().toString().split('.')[0]}
═══════════════════════════════════════════════════════════════
    ''';
  }

  /// Send test email to verify configuration
  static Future<EmailResult> sendTestEmail() async {
    return await sendContactForm(
      name: 'Test User',
      email: 'test@example.com',
      subject: 'Test Email - SMTP Configuration',
      message:
          'This is a test email to verify the Gmail SMTP configuration is working correctly.',
    );
  }

  /// Verify SMTP connection by sending a test email
  static Future<bool> verifySmtpConnection() async {
    try {
      // Try to send a test email to verify credentials
      final result = await sendTestEmail();
      return result.success;
    } catch (e) {
      print('SMTP Connection Error: $e');
      return false;
    }
  }
}

/// Email result class
class EmailResult {
  final bool success;
  final String message;
  final String? report;

  EmailResult({
    required this.success,
    required this.message,
    this.report,
  });
}
