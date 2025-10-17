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

  LinearGradient _getJobGradient() {
    // Use job's specific gradient colors if available, otherwise fallback to default
    if (widget.job.gradientColors.isNotEmpty) {
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: widget.job.gradientColors,
      );
    }

    // Fallback to default gradient - Dark colors for better white text contrast
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 37, 99, 235),
        Color.fromARGB(255, 147, 51, 234),
      ],
    );
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
        builder: (final context) => const Center(
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
          decoration: BoxDecoration(
            gradient: _getJobGradient(),
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
                gradient: _getJobGradient(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getJobGradient().colors.first.withOpacity(0.3),
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
                          child: widget.job.publisher.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    'https://www.topjobs.lk/logo/${widget.job.publisher}',
                                    width: 44,
                                    height: 24,
                                    fit: BoxFit.contain,
                                    errorBuilder: (final context, final error,
                                        final stackTrace) {
                                      return const Icon(
                                        Icons.work,
                                        color: Colors.white,
                                        size: 24,
                                      );
                                    },
                                    loadingBuilder: (final context, final child,
                                        final loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Center(
                                          child: SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
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
                              Text(
                                widget.job.company,
                                style: TextStyle(
                                  fontSize: 12,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SizedBox(
                height: 100,
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
            ),

            // Step Content - Flexible layout to prevent overflow
            Flexible(
              child: Container(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                    // color: Theme.of(context).cardTheme.color,
                    // borderRadius: BorderRadius.circular(0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.05),
                    //     blurRadius: 10,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                    ),
                child: Column(
                  children: [
                    // Step content - scrollable to prevent overflow
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: _getStepContent(),
                      ),
                    ),

                    // Navigation buttons - fixed at bottom
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        // color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.only(
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
                                      color:
                                          Color.fromARGB(255, 223, 223, 223)),
                                  foregroundColor: Colors.grey.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Previous'),
                                  ],
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 16),
                          Expanded(
                            child: _isButtonEnabled()
                                ? DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: _getJobGradient(),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _getNextButtonAction(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_getNextButtonText()),
                                          const SizedBox(width: 8),
                                          if (_currentStep == 2)
                                            const Icon(
                                              Icons.send,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade400,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_getNextButtonText()),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _currentStep == 2
                                              ? Icons.send
                                              : Icons.arrow_forward,
                                          size: 18,
                                        ),
                                      ],
                                    ),
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
        return 'Cover Letter & CV';
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

  bool _isButtonEnabled() {
    if (_currentStep == 0) {
      return _isStep1Valid();
    } else if (_currentStep == 1) {
      return _isStep2Valid();
    } else {
      // For Step 3 (Submit Application), validate all mandatory fields
      return _isStep1Valid() && _isStep2Valid() && !_isLoading;
    }
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step number circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isCompleted || isActive ? _getJobGradient() : null,
                color: isCompleted || isActive ? null : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive || isCompleted
                      ? _getJobGradient().colors.first
                      : Colors.grey.shade400,
                  width: 1,
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
            const SizedBox(height: 6),
            // Step title
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive || isCompleted
                      ? _getJobGradient().colors.first
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build step connector
  Widget _buildStepConnector(final bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: isCompleted ? _getJobGradient() : null,
          color: isCompleted ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  // Step 1: Personal Information
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name Field
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            children: const [
              TextSpan(text: 'Full Name '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.person),
            prefixIconColor: Colors.grey.shade600,
            prefixStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            labelText: 'Enter your full name',
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Phone Number Field
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            children: const [
              TextSpan(text: 'Phone Number '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Enter your phone number',
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            prefixIconColor: Colors.grey.shade600,
            prefixStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          keyboardType: TextInputType.phone,
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Email Address Field
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            children: const [
              TextSpan(text: 'Email Address '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Enter your email address',
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            prefixIconColor: Colors.grey.shade600,
            prefixStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // LinkedIn ID Field
        Text(
          'LinkedIn ID (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _linkedinController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Enter your LinkedIn profile URL',
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            prefixIconColor: Colors.grey.shade600,
            prefixStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  // Step 2: Cover Letter & CV
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Letter Field
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            children: const [
              TextSpan(text: 'Cover Letter '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _coverLetterController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Write your cover letter here...',
            hintStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Icon(Icons.description),
            ),
            prefixIconColor: Colors.grey.shade600,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          maxLines: 6,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (final value) => setState(() {}),
        ),
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            children: const [
              TextSpan(text: 'Resume Upload '),
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _resumeFile != null
                  ? _getJobGradient().colors.first
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _resumeFile != null
                ? _getJobGradient().colors.first.withOpacity(0.1)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                Icons.upload_file,
                size: 48,
                color: _resumeFile != null
                    ? _getJobGradient().colors.first
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                _resumeFile != null ? 'Resume Selected' : 'Upload Resume',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _resumeFile != null
                      ? _getJobGradient().colors.first
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
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _getJobGradient(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  onPressed: _pickResume,
                  icon: const Icon(Icons.attach_file),
                  label:
                      Text(_resumeFile != null ? 'Change File' : 'Select File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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

        // Cover Letter & CV Review
        _buildReviewSection(
          'Cover Letter & CV',
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
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment:
            isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            // width: 100,
            child: Text(
              '$label : ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 48, 48, 48),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
