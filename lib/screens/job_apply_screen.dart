// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../services/email_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/job_provider.dart';
import '../services/web_scraping_service.dart';

class JobApplyScreen extends StatefulWidget {
  const JobApplyScreen({
    super.key,
    required this.job,
    required this.scrapedContent,
  });

  final Job job;
  final ScrapedJobContent scrapedContent;

  @override
  State<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends State<JobApplyScreen> {
  // Stepper state
  int _currentStep = 0;

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();

  // File upload state
  File? _resumeFile;
  String? _resumeFileName;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Set company email if available
    // if (widget.scrapedContent.companyEmail != null &&
    //     widget.scrapedContent.companyEmail!.isNotEmpty) {
    //   _companyEmailController.text = widget.scrapedContent.companyEmail!;
    // }
    // Set company email for development
    _companyEmailController.text = 'heshan@genesiis.com';

    // Set default subject
  }

  // Stepper control methods
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // File picker method - using file_picker 10.3.3 for Android and iOS
  Future<void> _pickResume() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Using file_picker 10.3.3 with custom file type filtering
      // This version has better Android and iOS support
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Additional validation for file type
        final fileName = file.name.toLowerCase();
        final supportedExtensions = ['.pdf', '.doc', '.docx'];
        final isSupported =
            supportedExtensions.any((final ext) => fileName.endsWith(ext));

        if (!isSupported) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a PDF, DOC, or DOCX file'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        if (file.path != null) {
          setState(() {
            _resumeFile = File(file.path!);
            _resumeFileName = file.name;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File selected: ${file.name}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('File path is null');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Validation methods
  bool _isStep1Valid() {
    return _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  bool _isStep2Valid() {
    return _coverLetterController.text.isNotEmpty && _resumeFile != null;
  }

  Future<void> _sendEmail() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Send job application email
      final result = await EmailService.sendJobApplication(
        applicantName: _fullNameController.text,
        applicantEmail: _emailController.text,
        applicantPhone: _phoneController.text,
        linkedinId: _linkedinController.text,
        coverLetter: _coverLetterController.text,
        jobTitle: widget.job.title,
        companyName: widget.job.company,
        jobId: widget.job.jobId,
        jobLocation: widget.job.location,
        resumeFileName: _resumeFileName,
        resumeFile: _resumeFile,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (result.success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to job detail screen
        Navigator.of(context).pop();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending application: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _coverLetterController.dispose();
    _companyEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF37B307),
                Color(0xFF2A8B00),
              ],
            ),
          ),
        ),
        title: Text(
          _getStepTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Job Information Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF37B307),
                    Color(0xFF2A8B00),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF37B307).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.work,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.job.company,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.tag,
                          text: 'Job ID: ${widget.job.jobId}',
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.location_on,
                          text: widget.job.location,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Stepper
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Step 1
                  Expanded(
                    child: _buildHorizontalStep(
                      stepNumber: 1,
                      title: 'Personal\nInformation',
                      isActive: _currentStep == 0,
                      isCompleted: _currentStep > 0,
                      onTap: () => setState(() => _currentStep = 0),
                    ),
                  ),
                  _buildStepConnector(_currentStep > 0),
                  // Step 2
                  Expanded(
                    child: _buildHorizontalStep(
                      stepNumber: 2,
                      title: 'Additional\nInformation',
                      isActive: _currentStep == 1,
                      isCompleted: _currentStep > 1,
                      onTap: () => setState(() => _currentStep = 1),
                    ),
                  ),
                  _buildStepConnector(_currentStep > 1),
                  // Step 3
                  Expanded(
                    child: _buildHorizontalStep(
                      stepNumber: 3,
                      title: 'Review &\nSubmit',
                      isActive: _currentStep == 2,
                      isCompleted: false,
                      onTap: () => setState(() => _currentStep = 2),
                    ),
                  ),
                ],
              ),
            ),

            // Step Content - Flexible layout to prevent overflow
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Step content - scrollable to prevent overflow
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _getStepContent(),
                      ),
                    ),

                    // Navigation buttons - fixed at bottom
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousStep,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF37B307)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Previous'),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _getNextButtonAction(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF37B307),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(_getNextButtonText()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for stepper
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Additional Information';
      case 2:
        return 'Review & Submit';
      default:
        return 'Job Application';
    }
  }

  String _getNextButtonText() {
    if (_currentStep == 2) {
      return 'Submit Application';
    }
    return 'Continue';
  }

  VoidCallback? _getNextButtonAction() {
    if (_currentStep == 0) {
      return _isStep1Valid() ? _nextStep : null;
    } else if (_currentStep == 1) {
      return _isStep2Valid() ? _nextStep : null;
    } else {
      return _isLoading ? null : _sendEmail;
    }
  }

  // Get current step content
  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  // Build horizontal step widget
  Widget _buildHorizontalStep({
    required final int stepNumber,
    required final String title,
    required final bool isActive,
    required final bool isCompleted,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Step number circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF37B307)
                    : isActive
                        ? const Color(0xFF37B307)
                        : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isActive ? const Color(0xFF37B307) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            // Step title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF37B307)
                    : isCompleted
                        ? const Color(0xFF37B307)
                        : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build step connector
  Widget _buildStepConnector(final bool isCompleted) {
    return Container(
      height: 2,
      width: 20,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF37B307) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // Step 1: Personal Information
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF37B307),
                width: 2,
              ),
            ),
          ),
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF37B307),
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address *',
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF37B307),
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _linkedinController,
          decoration: InputDecoration(
            labelText: 'LinkedIn ID (Optional)',
            hintText: 'Enter your LinkedIn profile URL',
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF37B307),
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  // Step 2: Additional Information
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _coverLetterController,
          decoration: InputDecoration(
            labelText: 'Cover Letter *',
            hintText: 'Write your cover letter here...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Icon(Icons.description),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF37B307),
                width: 2,
              ),
            ),
          ),
          maxLines: 6,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 20),
        Text(
          'Resume Upload *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _resumeFile != null
                  ? const Color(0xFF37B307)
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _resumeFile != null
                ? const Color(0xFF37B307).withOpacity(0.1)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: _resumeFile != null
                    ? const Color(0xFF37B307)
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                _resumeFile != null ? 'Resume Selected' : 'Upload Resume',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _resumeFile != null
                      ? const Color(0xFF37B307)
                      : Colors.grey.shade600,
                ),
              ),
              if (_resumeFile != null) ...[
                const SizedBox(height: 4),
                Text(
                  _resumeFileName!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Supported formats: PDF, DOC, DOCX',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickResume,
                icon: const Icon(Icons.attach_file),
                label:
                    Text(_resumeFile != null ? 'Change File' : 'Select File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37B307),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Review All Details
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information Review
        _buildReviewSection(
          'Personal Information',
          [
            _buildReviewItem('Full Name', _fullNameController.text),
            _buildReviewItem('Phone', _phoneController.text),
            _buildReviewItem('Email', _emailController.text),
            if (_linkedinController.text.isNotEmpty)
              _buildReviewItem('LinkedIn', _linkedinController.text),
          ],
        ),
        const SizedBox(height: 20),

        // Additional Information Review
        _buildReviewSection(
          'Additional Information',
          [
            _buildReviewItem('Cover Letter', _coverLetterController.text,
                isLongText: true),
            _buildReviewItem('Resume', _resumeFileName ?? 'Not selected'),
          ],
        ),
        const SizedBox(height: 20),

        // Email Preview
        _buildReviewSection(
          'Email Preview',
          [
            _buildReviewItem('To', _companyEmailController.text),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewSection(final String title, final List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF37B307),
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(final String label, final String value,
      {final bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
              maxLines: isLongText ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required final IconData icon,
    required final String text,
    required final Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
