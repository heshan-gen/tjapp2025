// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../providers/job_provider.dart';
import '../providers/theme_provider.dart';
import '../services/company_service.dart';
import '../services/web_scraping_service.dart';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/job_rating_widget.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.job});
  final Job job;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  String? _companyInfo;
  bool _isLoadingCompanyInfo = true;
  ScrapedJobContent? _scrapedContent;
  bool _isLoadingScrapedContent = false;
  String? _scrapingError;

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

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
    _loadScrapedContent();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final companyInfo =
          await CompanyService.getCompanyInfo(widget.job.company);
      if (mounted) {
        setState(() {
          _companyInfo = companyInfo;
          _isLoadingCompanyInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _companyInfo =
              'Learn more about ${widget.job.company} and their career opportunities. Visit their website for detailed information about the company culture, values, and available positions.';
          _isLoadingCompanyInfo = false;
        });
      }
    }
  }

  Future<void> _loadScrapedContent() async {
    setState(() {
      _isLoadingScrapedContent = true;
      _scrapingError = null;
    });

    try {
      final applicationUrl = _generateApplicationUrl();
      final scrapedContent =
          await WebScrapingService.fetchJobDescription(applicationUrl);

      if (mounted) {
        setState(() {
          _scrapedContent = scrapedContent;
          _isLoadingScrapedContent = false;
          if (scrapedContent == null) {
            _scrapingError = 'Unable to fetch additional job details';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingScrapedContent = false;
          _scrapingError = 'Failed to load additional details: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _retryScraping() async {
    await _loadScrapedContent();
  }

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
        title: const Text(
          'Job Details',
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
          Consumer<JobProvider>(
            builder: (final context, final jobProvider, final child) {
              final isFavorite = jobProvider.isJobFavorite(widget.job.comments);
              return Container(
                margin: EdgeInsets.zero,
                // decoration: BoxDecoration(
                //   color: Colors.white.withOpacity(0.2),
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    jobProvider.toggleFavorite(widget.job.comments);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Job removed from favorites'
                              : 'Job saved to favorites',
                        ),
                        backgroundColor: isFavorite
                            ? const Color.fromARGB(255, 252, 144, 12)
                            : const Color.fromARGB(255, 5, 177, 56),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobHeader(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildJobInfo(),
                  const SizedBox(height: 20),
                  _buildJobDescription(),
                  const SizedBox(height: 20),
                  _buildRequirements(),
                  if (widget.job.skills.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSkills(context),
                  ],
                  if (widget.job.company.toLowerCase() !=
                      'company name withheld') ...[
                    const SizedBox(height: 20),
                    _buildCompanyInfo(context),
                  ],
                  const SizedBox(height: 20),
                  _buildRatingSection(context),
                  const SizedBox(
                      height: 20), // Add bottom padding for fixed footer
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: _buildActionButtons(context),
        ),
      ),
    );
  }

  Widget _buildJobHeader(final BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: _getJobGradient(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.job.publisher == 'defzzz.gif'
                    ? // Show only hot icon for defzzz.gif
                    Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                          size: 32,
                        ),
                      )
                    : Container(
                        width: 160,
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: widget.job.publisher.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'https://www.topjobs.lk/logo/${widget.job.publisher}',
                                  width: 140,
                                  height: 70,
                                  fit: BoxFit.fitHeight,
                                  errorBuilder: (final context, final error,
                                      final stackTrace) {
                                    return const Icon(
                                      Icons.work,
                                      color: Colors.white,
                                      size: 35,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.work,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                const SizedBox(height: 16),
                Text(
                  widget.job.title
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .replaceAll('?', '-'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.job.company.trim().replaceAll(RegExp(r'\s+'), ' '),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoChip(
                      icon: Icons.location_on,
                      text: widget.job.location,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    if (widget.job.isRemote) ...[
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.home_work,
                        text: 'Remote',
                        color: Colors.greenAccent,
                        backgroundColor: Colors.greenAccent.withOpacity(0.2),
                      ),
                    ],
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.attach_money,
                      text: widget.job.salary,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.schedule,
                      text: widget.job.type,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBadge(
                      text: widget.job.type,
                      color: Theme.of(context).cardColor,
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      text: widget.job.experience,
                      color: Theme.of(context).cardColor,
                      backgroundColor: Colors.white.withOpacity(0.2),
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

  Widget _buildInfoChip({
    required final IconData icon,
    required final String text,
    required final Color color,
    final Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required final String text,
    required final Color color,
    required final Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0DA2DD).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFF0DA2DD),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Job Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Priority 1-2: Company and Location (most important)
            _buildInfoRowPair(
              'Company',
              widget.job.author.trim().replaceAll(RegExp(r'\s+'), ' '),
              Icons.business,
              'Location',
              widget.job.location,
              Icons.location_on,
            ),
            // Priority 3-4: Salary and Type (key decision factors)
            _buildInfoRowPair(
              'Salary',
              widget.job.salary,
              Icons.attach_money,
              'Type',
              widget.job.type,
              Icons.work_outline,
            ),
            // Priority 5-6: Experience and Posted Date
            _buildInfoRowPair(
              'Experience',
              widget.job.experience,
              Icons.trending_up,
              'Posted',
              _formatDate(widget.job.postedDate),
              Icons.schedule,
            ),
            // Priority 7-8: Closing Date and Job ID (if available)
            if (widget.job.closingDate != null)
              _buildInfoRowPair(
                'Closing Date',
                _formatDate(widget.job.closingDate!),
                Icons.event,
                'Job ID',
                widget.job.jobId.isNotEmpty ? widget.job.jobId : 'N/A',
                Icons.tag,
              ),
            // Additional info: Work Type (if remote)
            if (widget.job.isRemote)
              _buildInfoRowPair(
                'Work Type',
                'Remote',
                Icons.home_work,
                '',
                '',
                Icons.info,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowPair(
      final String label1,
      final String value1,
      final IconData icon1,
      final String label2,
      final String value2,
      final IconData icon2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoRow(label1, value1, icon1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: label2.isEmpty
                ? const SizedBox()
                : _buildInfoRow(label2, value2, icon2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      final String label, final String value, final IconData icon) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
          // color: const Color(0xFFF8FAFC),
          // borderRadius: BorderRadius.circular(10),
          // border: Border.all(
          //   color: const Color(0xFFE2E8F0),
          //   width: 1,
          // ),
          ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 138, 138, 138).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleSmall?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                  // color: const Color(0xFFF8FAFC),
                  // borderRadius: BorderRadius.circular(12),
                  // border: Border.all(
                  //   color: const Color(0xFFE2E8F0),
                  //   width: 1,
                  // ),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show original description first
                  Text(
                    widget.job.description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),

                  // Show loading indicator for scraped content
                  if (_isLoadingScrapedContent) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LoadingAnimationWidget.beat(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ],

                  // Show error message with retry button
                  if (_scrapingError != null && !_isLoadingScrapedContent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: Colors.orange[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _scrapingError!,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _retryScraping,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Show scraped content if available
                  if (_scrapedContent != null && !_isLoadingScrapedContent) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE2E8F0)),
                    // const SizedBox(height: 16),
                    // const Text(
                    //   'Additional Details',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.bold,
                    //     color: Theme.of(context).textTheme.titleMedium?.color,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      _scrapedContent!.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    // Display images if available
                    if (_scrapedContent!.imageUrls.isNotEmpty) ...[
                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Images',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.bold,
                      //     color: Theme.of(context).textTheme.titleMedium?.color,
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      ..._scrapedContent!.imageUrls.asMap().entries.map(
                        (final entry) {
                          final index = entry.key;
                          final imageUrl = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                showImageViewer(
                                  context,
                                  imageUrl,
                                  title: 'Artwork ${index + 1}',
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (final context, final error,
                                          final stackTrace) {
                                        return Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 48,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Zoom icon overlay
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.checklist_outlined,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Requirements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.job.requirements,
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkills(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.stars_outlined,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Required Skills',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.job.skills.map((final skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF7C3AED),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    color: Color(0xFF06B6D4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'About Company',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF06B6D4),
                          Color(0xFF0891B2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF06B6D4).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.company
                              .trim()
                              .replaceAll(RegExp(r'\s+'), ' '),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoadingCompanyInfo)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LoadingAnimationWidget.beat(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              )
            else
              Text(
                _companyInfo ?? 'About Company',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Open map with company location
                _openMap();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF06B6D4),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'View on Map',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF06B6D4),
                        fontWeight: FontWeight.w500,
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

  Future<void> _openMap() async {
    try {
      // You can customize this URL based on your needs
      // This will open the default map app with a search for the company name
      final companyName = widget.job.company.trim();
      final encodedCompany = Uri.encodeComponent(companyName);
      final mapUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedCompany';

      final Uri uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to a general search
        final fallbackUrl =
            'https://www.google.com/maps/search/$encodedCompany';
        final Uri fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Error opening map: $e');
      // You could show a snackbar or dialog here to inform the user
    }
  }

  Future<void> _launchApplicationUrl() async {
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

    try {
      if (await canLaunchUrl(toLaunch)) {
        await launchUrl(toLaunch, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $toLaunch');
      }
    } catch (e) {
      // Handle error - you might want to show a snackbar or dialog
      print('Error launching URL: $e');
    }
  }

  Future<void> _shareJob() async {
    final Uri shareUrl = Uri(
      scheme: 'https',
      host: 'www.topjobs.lk',
      path: 'employer/JobAdvertismentServlet',
      queryParameters: {
        'ac': widget.job.applicantCode,
        'jc': widget.job.comments,
        'ec': widget.job.guid,
      },
    );

    // Create Google Maps URL for company location
    final String companyName = widget.job.company.trim();
    final String location = widget.job.location.trim();
    final String mapQuery = '$companyName, $location';
    final String encodedMapQuery = Uri.encodeComponent(mapQuery);
    final String mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedMapQuery';

    final String shareText = 'Check out this job opportunity!\n\n'
        '${widget.job.title} at ${widget.job.company}\n'
        'Location: ${widget.job.location}\n'
        'Salary: ${widget.job.salary}\n'
        'Type: ${widget.job.type}\n\n'
        '📍 Company Location: $mapUrl\n'
        '🔗 Apply here: ${shareUrl.toString()}';

    try {
      // Check if there are images available to share
      if (_scrapedContent != null && _scrapedContent!.imageUrls.isNotEmpty) {
        // Try to download image with timeout to avoid long delays
        try {
          final String imageUrl = _scrapedContent!.imageUrls.first;
          final File? imageFile = await _downloadImageWithTimeout(imageUrl);

          if (imageFile != null) {
            // Share with image and text
            await Share.shareXFiles(
              [XFile(imageFile.path)],
              text: shareText,
            );
          } else {
            // Fallback to text-only sharing if image download fails
            await Share.share(shareText);
          }
        } catch (e) {
          // If image download times out or fails, share text only
          print('Image download failed, sharing text only: $e');
          await Share.share(shareText);
        }
      } else {
        // No images available, share text only
        await Share.share(shareText);
      }
    } catch (e) {
      print('Error sharing job: $e');
    }
  }

  // Download image with timeout to prevent long delays
  Future<File?> _downloadImageWithTimeout(final String imageUrl) async {
    try {
      return await Future.any([
        _downloadImage(imageUrl),
        Future.delayed(const Duration(seconds: 5), () => null),
      ]);
    } catch (e) {
      print('Image download timeout or error: $e');
      return null;
    }
  }

  Future<File?> _downloadImage(final String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName =
            'job_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  Widget _buildActionButtons(final BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: OutlinedButton(
              onPressed: _shareJob,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                side: BorderSide.none,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_outlined,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF37B307),
                  Color.fromARGB(255, 55, 179, 7),
                  Color.fromARGB(255, 4, 109, 18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF37B307).withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _launchApplicationUrl,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Apply Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(5),
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFFFFA726),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Rate this Job',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating input
            JobRatingWidget(
              jobComments: widget.job.comments,
              averageRating: widget.job.averageRating,
              totalRatings: widget.job.totalRatings,
              showRatingInput: true,
              onRatingChanged: () {
                // Refresh the job data when rating changes
                context
                    .read<JobProvider>()
                    .refreshJobRating(widget.job.comments);
              },
            ),

            const SizedBox(height: 16),

            // Rating stats
            if (widget.job.totalRatings > 0)
              JobRatingStatsWidget(
                jobComments: widget.job.comments,
                averageRating: widget.job.averageRating,
                totalRatings: widget.job.totalRatings,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(final DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays > 0) {
      // Past dates
      return '${difference.inDays} days ago';
    } else {
      // Future dates - use absolute value
      final daysUntil = difference.inDays.abs();
      if (daysUntil == 1) {
        return 'Tomorrow';
      } else {
        return 'In $daysUntil days';
      }
    }
  }
}
