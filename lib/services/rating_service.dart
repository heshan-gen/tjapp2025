import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'job_ratings';

  /// Submit a rating for a job
  static Future<bool> submitRating({
    required final String jobComments,
    required final int rating,
    required final String userId,
  }) async {
    try {
      final ratingData = {
        'jobComments': jobComments,
        'rating': rating,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Use jobComments as document ID for easy querying
      await _firestore
          .collection(_collectionName)
          .doc('${jobComments}_$userId')
          .set(ratingData);

      return true;
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    }
  }

  /// Get rating statistics for a job
  static Future<Map<String, dynamic>> getJobRatingStats(
      final String jobComments) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('jobComments', isEqualTo: jobComments)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalRatings': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      int totalRatings = 0;
      double totalScore = 0.0;
      final Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final rating = data['rating'] as int;
        totalRatings++;
        totalScore += rating;
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      final averageRating = totalRatings > 0 ? totalScore / totalRatings : 0.0;

      return {
        'averageRating': averageRating,
        'totalRatings': totalRatings,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      print('Error getting job rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalRatings': 0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }

  /// Get user's rating for a specific job
  static Future<int?> getUserRating(
      final String jobComments, final String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc('${jobComments}_$userId')
          .get();

      if (doc.exists) {
        return doc.data()?['rating'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting user rating: $e');
      return null;
    }
  }

  /// Update user's rating for a job
  static Future<bool> updateRating({
    required final String jobComments,
    required final int rating,
    required final String userId,
  }) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc('${jobComments}_$userId')
          .update({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating rating: $e');
      return false;
    }
  }

  /// Delete user's rating for a job
  static Future<bool> deleteRating(
      final String jobComments, final String userId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc('${jobComments}_$userId')
          .delete();
      return true;
    } catch (e) {
      print('Error deleting rating: $e');
      return false;
    }
  }

  /// Get all ratings for a job (for admin purposes)
  static Future<List<Map<String, dynamic>>> getJobRatings(
      final String jobComments) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('jobComments', isEqualTo: jobComments)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((final doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'rating': data['rating'],
          'userId': data['userId'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      print('Error getting job ratings: $e');
      return [];
    }
  }
}
