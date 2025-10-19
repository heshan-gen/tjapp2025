import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppliedJobsService {
  static const String _appliedJobsKey = 'applied_job_ids';
  static const String _appliedJobsDetailsKey = 'applied_jobs_details';

  /// Save a job as applied
  static Future<bool> saveAppliedJob(
      final String jobComments, final Map<String, dynamic> jobDetails) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing applied job IDs
      final List<String> appliedJobIds =
          prefs.getStringList(_appliedJobsKey) ?? [];

      // Add new job ID if not already applied
      if (!appliedJobIds.contains(jobComments)) {
        appliedJobIds.add(jobComments);
        await prefs.setStringList(_appliedJobsKey, appliedJobIds);
      }

      // Save detailed job information
      Map<String, dynamic> appliedJobsDetails = {};
      final String? existingDetails = prefs.getString(_appliedJobsDetailsKey);
      if (existingDetails != null) {
        appliedJobsDetails =
            Map<String, dynamic>.from(json.decode(existingDetails));
      }

      appliedJobsDetails[jobComments] = {
        ...jobDetails,
        'appliedDate': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
          _appliedJobsDetailsKey, json.encode(appliedJobsDetails));

      return true;
    } catch (e) {
      print('Error saving applied job: $e');
      return false;
    }
  }

  /// Save document file path for a job
  static Future<bool> saveDocumentPath(
      final String jobComments, final String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String documentPathsKey = 'document_paths_$jobComments';

      await prefs.setString(documentPathsKey, filePath);
      return true;
    } catch (e) {
      print('Error saving document path: $e');
      return false;
    }
  }

  /// Get document file path for a job
  static Future<String?> getDocumentPath(final String jobComments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String documentPathsKey = 'document_paths_$jobComments';

      return prefs.getString(documentPathsKey);
    } catch (e) {
      print('Error getting document path: $e');
      return null;
    }
  }

  /// Check if a job has been applied to
  static Future<bool> isJobApplied(final String jobComments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> appliedJobIds =
          prefs.getStringList(_appliedJobsKey) ?? [];
      return appliedJobIds.contains(jobComments);
    } catch (e) {
      print('Error checking if job is applied: $e');
      return false;
    }
  }

  /// Get all applied job IDs
  static Future<List<String>> getAppliedJobIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_appliedJobsKey) ?? [];
    } catch (e) {
      print('Error getting applied job IDs: $e');
      return [];
    }
  }

  /// Get applied job details
  static Future<Map<String, dynamic>?> getAppliedJobDetails(
      final String jobComments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? detailsJson = prefs.getString(_appliedJobsDetailsKey);
      if (detailsJson != null) {
        final Map<String, dynamic> details =
            Map<String, dynamic>.from(json.decode(detailsJson));
        return details[jobComments];
      }
      return null;
    } catch (e) {
      print('Error getting applied job details: $e');
      return null;
    }
  }

  /// Get all applied jobs details
  static Future<Map<String, dynamic>> getAllAppliedJobsDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? detailsJson = prefs.getString(_appliedJobsDetailsKey);
      if (detailsJson != null) {
        return Map<String, dynamic>.from(json.decode(detailsJson));
      }
      return {};
    } catch (e) {
      print('Error getting all applied jobs details: $e');
      return {};
    }
  }

  /// Remove a job from applied jobs (if needed)
  static Future<bool> removeAppliedJob(final String jobComments) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove from applied job IDs
      final List<String> appliedJobIds =
          prefs.getStringList(_appliedJobsKey) ?? [];
      appliedJobIds.remove(jobComments);
      await prefs.setStringList(_appliedJobsKey, appliedJobIds);

      // Remove from details
      Map<String, dynamic> appliedJobsDetails = {};
      final String? existingDetails = prefs.getString(_appliedJobsDetailsKey);
      if (existingDetails != null) {
        appliedJobsDetails =
            Map<String, dynamic>.from(json.decode(existingDetails));
      }
      appliedJobsDetails.remove(jobComments);
      await prefs.setString(
          _appliedJobsDetailsKey, json.encode(appliedJobsDetails));

      return true;
    } catch (e) {
      print('Error removing applied job: $e');
      return false;
    }
  }

  /// Clear all applied jobs (if needed)
  static Future<bool> clearAllAppliedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_appliedJobsKey);
      await prefs.remove(_appliedJobsDetailsKey);
      return true;
    } catch (e) {
      print('Error clearing applied jobs: $e');
      return false;
    }
  }
}
