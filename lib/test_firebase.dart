import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseTest {
  static Future<void> testConnection() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print('✅ Firebase initialized successfully');

      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      final testDoc = firestore.collection('test').doc('connection_test');

      // Try to write a test document
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Connection test successful',
      });

      print('✅ Firestore write test successful');

      // Try to read the document
      final doc = await testDoc.get();
      if (doc.exists) {
        print('✅ Firestore read test successful');
        print('📄 Document data: ${doc.data()}');
      }

      // Test job_views collection
      final jobViewsRef = firestore.collection('job_views').doc('test_job');
      await jobViewsRef.set({
        'jobComments': 'test_job',
        'viewCount': 1,
        'firstViewed': FieldValue.serverTimestamp(),
        'lastViewed': FieldValue.serverTimestamp(),
      });

      print('✅ Job views collection test successful');

      // Clean up test documents
      await testDoc.delete();
      await jobViewsRef.delete();

      print('✅ All Firebase tests passed!');
    } catch (e) {
      print('❌ Firebase test failed: $e');
    }
  }
}
