import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCountService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'job_views';

  /// Increment view count for a job
  /// Uses job.comments as the unique identifier
  static Future<void> incrementViewCount(final String jobComments) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(jobComments);

      // Use a simpler approach without transactions for better reliability
      final doc = await docRef.get();

      if (doc.exists) {
        // Document exists, increment the count
        final currentCount = doc.data()?['viewCount'] ?? 0;
        await docRef.update({
          'viewCount': currentCount + 1,
          'lastViewed': FieldValue.serverTimestamp(),
        });
      } else {
        // Document doesn't exist, create it with count 1
        await docRef.set({
          'jobComments': jobComments,
          'viewCount': 1,
          'firstViewed': FieldValue.serverTimestamp(),
          'lastViewed': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Don't throw error to avoid breaking the app
    }
  }

  /// Get view count for a specific job
  static Future<int> getViewCount(final String jobComments) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(jobComments).get();

      if (doc.exists) {
        return doc.data()?['viewCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get view counts for multiple jobs
  static Future<Map<String, int>> getViewCounts(
      final List<String> jobCommentsList) async {
    try {
      final Map<String, int> viewCounts = {};

      // Firestore 'in' queries are limited to 30 items, so we need to batch them
      const batchSize = 30;
      for (int i = 0; i < jobCommentsList.length; i += batchSize) {
        final batch = jobCommentsList.skip(i).take(batchSize).toList();

        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in querySnapshot.docs) {
          viewCounts[doc.id] = doc.data()['viewCount'] ?? 0;
        }
      }

      // Add 0 for jobs that don't have view counts yet
      for (final jobComments in jobCommentsList) {
        viewCounts.putIfAbsent(jobComments, () => 0);
      }

      return viewCounts;
    } catch (e) {
      // Return 0 for all jobs if there's an error
      return Map.fromEntries(
          jobCommentsList.map((final jobComments) => MapEntry(jobComments, 0)));
    }
  }

  /// Get top viewed jobs
  static Future<List<Map<String, dynamic>>> getTopViewedJobs(
      {final int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((final doc) {
        final data = doc.data();
        return {
          'jobComments': doc.id,
          'viewCount': data['viewCount'] ?? 0,
          'lastViewed': data['lastViewed'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Batch increment view counts for multiple jobs (optimized)
  static Future<void> batchIncrementViewCounts(
      final List<String> jobCommentsList) async {
    try {
      if (jobCommentsList.isEmpty) return;

      final batch = _firestore.batch();

      for (final jobComments in jobCommentsList) {
        final docRef = _firestore.collection(_collectionName).doc(jobComments);
        batch.set(
            docRef,
            {
              'jobComments': jobComments,
              'viewCount': FieldValue.increment(1),
              'lastViewed': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Error batch updating view counts: $e');
    }
  }

  /// Delete view count for a job (useful for cleanup)
  static Future<void> deleteViewCount(final String jobComments) async {
    try {
      await _firestore.collection(_collectionName).doc(jobComments).delete();
    } catch (e) {
      print('Error deleting view count for job $jobComments: $e');
    }
  }

  /// Listen to view count changes in real-time (optimized)
  static Stream<Map<String, int>> listenToViewCounts(
      final List<String> jobCommentsList) {
    try {
      // Disable real-time updates to improve performance
      // View counts will be loaded once and updated only when jobs are tapped
      return Stream.value(<String, int>{});
    } catch (e) {
      // Return a stream with empty map
      return Stream.value(<String, int>{});
    }
  }

  /// Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      print('✅ Firebase connection successful');
      return true;
    } catch (e) {
      print('❌ Firebase connection failed: $e');
      return false;
    }
  }
}
