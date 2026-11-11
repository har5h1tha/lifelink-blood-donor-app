import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

/// A friendly error the ViewModel can show directly.
/// The ViewModel never sees Firebase's own exception types.
class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);
}

/// Talks to Firebase Auth and Firestore. No UI, no state.
class AuthService {
  // Getters (not fields) so Firebase is touched only when a method is called.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String city,
    required String phone,
  }) async {
    try {
      // Step 1: create the login account (email + password) in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Step 2: save the profile in Firestore under users/{uid}
      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        bloodGroup: bloodGroup,
        city: city,
        phone: phone,
      );
      await saveProfile(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendly(e.code));
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await fetchProfile(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_friendly(e.code));
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel?> fetchProfile(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> saveProfile(UserModel user) {
    return _db.collection(usersCollection).doc(user.uid).set(user.toMap());
  }

  String _friendly(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
