import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user with email and password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Save donor data in Firestore with unique user ID (uid)
  Future<void> saveDonorData({
    required String uid,
    required String email,
    required String name,
    required String bloodGroup,
    required String phoneNumber,
    required String location,
  }) async {
    try {
      await _firestore.collection('donors').doc(uid).set({
        'email': email,
        'name': name,
        'bloodGroup': bloodGroup,
        'phoneNumber': phoneNumber,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save donor data: $e');
    }
  }

  // Login user with email and password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
