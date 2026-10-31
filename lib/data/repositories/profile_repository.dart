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

  static const usersCollection = 'Users';

  final FirebaseAuth _auth;
  final FirebaseFirestore _store;

  @override
  Future<UserProfile?> load() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    // Ensure Firestore receives refreshed email_verified claims after reload().
    await user.getIdToken(true);
    final document = await _store
        .collection(usersCollection)
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 20));
    final data = document.data();
    return data == null ? null : UserProfile.fromJson(data);
  }

  @override
  Future<void> save(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    await _store
        .collection(usersCollection)
        .doc(user.uid)
        .set({
      ...profile.toJson(),
      'uid': user.uid,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 20));
    await user.updateDisplayName(profile.name);
  }
}