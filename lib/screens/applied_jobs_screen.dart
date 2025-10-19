// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Consumer;
import '../providers/theme_provider.dart' show ThemeProvider;
import '../services/applied_jobs_service.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  List<Map<String, dynamic>> _appliedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppliedJobs();
  }

  Future<void> _loadAppliedJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appliedJobsDetails =
          await AppliedJobsService.getAllAppliedJobsDetails();
      final appliedJobsList = appliedJobsDetails.entries.map((final entry) {
        final jobData = Map<String, dynamic>.from(entry.value);
        jobData['jobComments'] = entry.key;
        return jobData;
      }).toList();

      // Sort by applied date (most recent first)
      appliedJobsList.sort((final a, final b) {
        final dateA = DateTime.parse(a['appliedDate'] ?? '');
        final dateB = DateTime.parse(b['appliedDate'] ?? '');
        return dateB.compareTo(dateA);
      });

      setState(() {
        _appliedJobs = appliedJobsList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading applied jobs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeAppliedJob(final String jobComments) async {
    try {
      final success = await AppliedJobsService.removeAppliedJob(jobComments);
      if (success) {
        setState(() {
          _appliedJobs
              .removeWhere((final job) => job['jobComments'] == jobComments);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job removed from applied jobs'),
            backgroundColor: const Color.fromARGB(255, 252, 144, 12),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('Error removing applied job: $e');
    }
  }

  String _formatAppliedDate(final String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatClosingDate(final String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays < 0) {
        return 'Closed';
      } else if (difference.inDays == 0) {
        return 'Closes today';
      } else if (difference.inDays == 1) {
        return 'Closes in 1 day';
      } else {
        return 'Closes in ${difference.inDays} days';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  Color _getClosingDateColor(final String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.inDays < 0) {
        return Colors.grey;
      } else if (difference.inDays < 3) {
        return Colors.red;
      } else if (difference.inDays <= 5) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Applied Jobs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (final context, final themeProvider, final child) {
              return IconButton(
                icon: Icon(themeProvider.themeIcon),
                tooltip: themeProvider.themeTooltip,
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          if (_appliedJobs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAppliedJobs,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _appliedJobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 80,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFF0BE28)
                            : Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Applied Jobs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jobs you apply to will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppliedJobs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _appliedJobs.length,
                    itemBuilder: (final context, final index) {
                      final job = _appliedJobs[index];
                      return _buildAppliedJobCard(job);
                    },
                  ),
                ),
    );
  }

  Widget _buildAppliedJobCard(final Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Company logo or default icon
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: job['publisher'] != null && job['publisher'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            'https://www.topjobs.lk/logo/${job['publisher']}',
                            width: 34,
                            height: 34,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (final context, final error, final stackTrace) {
                              return const Icon(
                                Icons.work,
                                color: Color(0xFF10B981),
                                size: 20,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.work,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title']
                                .trim()
                                .replaceAll(RegExp(r'\s+'), ' ')
                                .replaceAll('?', '-') ??
                            'Unknown Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company']
                                .trim()
                                .replaceAll(RegExp(r'\s+'), ' ')
                                .replaceAll('?', '-') ??
                            'Unknown Company',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (final value) {
                    if (value == 'remove') {
                      _removeAppliedJob(job['jobComments']);
                    }
                  },
                  itemBuilder: (final context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove'),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Job details row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (job['jobId'] != null && job['jobId'].isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.tag,
                    text: 'ID: ${job['jobId']}',
                  ),
                _buildInfoChip(
                  icon: Icons.location_on,
                  text: job['location'] ?? 'Unknown Location',
                ),
                _buildInfoChip(
                  icon: Icons.schedule,
                  text: _formatAppliedDate(job['appliedDate'] ?? ''),
                ),
                if (job['salary'] != null && job['salary'].isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.attach_money,
                    text: job['salary'],
                  ),
                if (job['type'] != null && job['type'].isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.work_outline,
                    text: job['type'],
                  ),
                if (job['isRemote'] == true)
                  _buildInfoChip(
                    icon: Icons.home_work,
                    text: 'Remote',
                    color: Colors.green,
                  ),
                if (job['experience'] != null && job['experience'].isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.trending_up,
                    text: job['experience'],
                    color: Colors.blue,
                  ),
                if (job['closingDate'] != null)
                  _buildInfoChip(
                    icon: Icons.event,
                    text: _formatClosingDate(job['closingDate']),
                    color: _getClosingDateColor(job['closingDate']),
                  ),
              ],
            ),
            // Skills section
            if (job['skills'] != null &&
                job['skills'].isNotEmpty &&
                job['skills'] is List &&
                (job['skills'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.purple[900]?.withOpacity(0.3)
                      : Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.purple[600]!
                        : Colors.purple[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.purple[300]
                              : Colors.purple[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Required Skills',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (job['skills'] as List)
                          .take(5)
                          .map<Widget>((final skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.purple[800]?.withOpacity(0.5)
                                    : Colors.purple[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.purple[600]!
                                  : Colors.purple[300]!,
                            ),
                          ),
                          child: Text(
                            skill.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.purple[200]
                                  : Colors.purple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if ((job['skills'] as List).length > 5) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${(job['skills'] as List).length - 5} more skills',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            // Job description preview
            if (job['description'] != null &&
                job['description'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]?.withOpacity(0.3)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[600]!
                        : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description,
                          size: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.blue[300]
                              : Colors.blue[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Job Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Name', job['applicantName'] ?? 'N/A'),
                  _buildDetailRow('Email', job['applicantEmail'] ?? 'N/A'),
                  _buildDetailRow('Phone', job['applicantPhone'] ?? 'N/A'),
                ],
              ),
            ),
            if (job['resumeFileName'] != null &&
                job['resumeFileName'].isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _viewDocument(job['resumeFileName']),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.green[900]?.withOpacity(0.3)
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[600]!
                          : Colors.green[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Attached Document',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            _getFileIcon(job['resumeFileName']),
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.green[300]
                                    : Colors.green[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              job['resumeFileName'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showDocumentInfo(job['resumeFileName']),
                            icon: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.green[300]
                                  : Colors.green[700],
                            ),
                            tooltip: 'Document Info',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (job['coverLetter'] != null &&
                job['coverLetter'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]?.withOpacity(0.3)
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[600]!
                        : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cover Letter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['coverLetter'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required final IconData icon,
    required final String text,
    final Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? (isDark ? Colors.grey[300] : Colors.grey[600]);
    final backgroundColor = color != null
        ? color.withOpacity(0.1)
        : (isDark ? Colors.grey[700] : Colors.grey[100]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border:
            color != null ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(final String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.attach_file;
    }
  }

  void _showDocumentInfo(final String fileName) {
    showDialog(
      context: context,
      builder: (final context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Row(
          children: [
            Icon(
              _getFileIcon(fileName),
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('Document Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('File Name', fileName),
            _buildInfoRow('File Type', fileName.split('.').last.toUpperCase()),
            _buildInfoRow('Status', 'Attached to Application'),
            const SizedBox(height: 8),
            Text(
              'This document was attached when you applied for this job. It has been sent to the employer along with your application.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(final String label, final String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewDocument(final String fileName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Find the job that contains this file name to get the job comments
      final jobWithDocument = _appliedJobs.firstWhere(
        (final job) => job['resumeFileName'] == fileName,
        orElse: () => <String, dynamic>{},
      );

      if (jobWithDocument.isEmpty) {
        // Close loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job not found for this document.'),
            backgroundColor: const Color.fromARGB(255, 252, 144, 12),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      // Get the saved document path from SharedPreferences
      final savedFilePath = await AppliedJobsService.getDocumentPath(
          jobWithDocument['jobComments']);

      if (savedFilePath != null) {
        final file = File(savedFilePath);

        // Check if file exists
        if (await file.exists()) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Open the file with the default app
          final result = await OpenFile.open(savedFilePath);

          if (result.type != ResultType.done) {
            // Show error if file couldn't be opened
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open file: ${result.message}'),
                backgroundColor: const Color.fromARGB(255, 220, 38, 38),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        } else {
          // Close loading dialog
          Navigator.of(context).pop();

          // Show error if file doesn't exist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Document file not found. It may have been moved or deleted.'),
              backgroundColor: const Color.fromARGB(255, 252, 144, 12),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error if no saved path found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Document path not found. This may be an older application without saved document.'),
            backgroundColor: const Color.fromARGB(255, 252, 144, 12),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: $e'),
          backgroundColor: const Color.fromARGB(255, 220, 38, 38),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
