import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> load();
  Future<void> save(UserProfile profile);
}

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _store = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _store;
  static const usersCollection = 'Users';
  static const studentsCollection = 'Student_Profiles';
  static const providersCollection = 'Service_Providers';

  @override
  Future<UserProfile?> load() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return null;
    await user.getIdToken(true);
    final document = await _store
        .collection(usersCollection)
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 20));
    final data = document.data();
    if (data == null) return null;
    final collection = data['user_role'] == 'Provider'
        ? providersCollection
        : studentsCollection;
    final details = await _store
        .collection(collection)
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 20));
    return UserProfile.fromDocuments(data, details.data() ?? {});
  }

  @override
  Future<void> save(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    if (!user.emailVerified) {
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    await user.getIdToken(true);
    final provider = profile.accountType == 'provider';
    final userRef = _store.collection(usersCollection).doc(user.uid);
    final detailsRef = _store
        .collection(provider ? providersCollection : studentsCollection)
        .doc(user.uid);
    // Both documents are committed together; retries preserve creation metadata.
    await _store
        .runTransaction((transaction) async {
          final existingUser = await transaction.get(userRef);
          final existingDetails = await transaction.get(detailsRef);
          transaction.set(userRef, {
            ...profile.toUserDocument(),
            'uid': user.uid,
            'email': user.email,
            if (!existingUser.exists) ...{
              'avatar_url': user.photoURL,
              'status': provider ? 'Pending-approval' : 'active',
              'created_at': FieldValue.serverTimestamp(),
            },
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          transaction.set(detailsRef, {
            ...profile.toDetailsDocument(),
            'user_id': user.uid,
            if (!existingDetails.exists && !provider) ...{
              'student_id': user.uid,
              'faculty': '',
              'academic_level': null,
              'bio': null,
            },
            if (!existingDetails.exists && provider) ...{
              'provider_id': user.uid,
              'bio_description': '',
              'address_details': '',
              'latitude': null,
              'longitude': null,
              'verification_status': 'pending',
              'average_rating': 0,
              'reviews_count': 0,
              'support_partial': false,
            },
          }, SetOptions(merge: true));
        })
        .timeout(const Duration(seconds: 20));
    await user.updateDisplayName(profile.name);
  }
}
