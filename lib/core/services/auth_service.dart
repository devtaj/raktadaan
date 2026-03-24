import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raktadan/core/constants/app_constants.dart';
import 'package:raktadan/core/utils/error_handler.dart';
import 'package:raktadan/core/utils/validators.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user with email and password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      if (!Validators.isValidEmail(email)) {
        throw Exception('Invalid email format');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      throw ErrorHandler.handleError(e);
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
      // Validate all inputs
      if (!Validators.isValidId(uid)) throw Exception('Invalid user ID');
      if (!Validators.isValidEmail(email)) throw Exception('Invalid email');
      if (!Validators.isValidName(name)) throw Exception('Invalid name');
      if (!Validators.isValidBloodGroup(bloodGroup)) throw Exception('Invalid blood group');
      if (!Validators.isValidPhone(phoneNumber)) throw Exception('Invalid phone number');
      if (!Validators.isValidLocation(location)) throw Exception('Invalid location');
      
      await _firestore.collection(AppConstants.donorsCollection).doc(uid).set({
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'bloodGroup': bloodGroup,
        'phoneNumber': phoneNumber.trim(),
        'location': location.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Login user with email and password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      if (!Validators.isValidEmail(email)) {
        throw Exception('Invalid email format');
      }
      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }
      
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return userCred.user;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get user data from Firestore
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      if (!Validators.isValidId(uid)) {
        throw Exception('Invalid user ID');
      }
      return await _firestore.collection(AppConstants.donorsCollection).doc(uid).get();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      if (!Validators.isValidId(uid)) {
        throw Exception('Invalid user ID');
      }
      if (data.isEmpty) {
        throw Exception('No data provided for update');
      }
      
      // Validate data fields if present
      if (data.containsKey('email') && !Validators.isValidEmail(data['email'])) {
        throw Exception('Invalid email in update data');
      }
      if (data.containsKey('name') && !Validators.isValidName(data['name'])) {
        throw Exception('Invalid name in update data');
      }
      if (data.containsKey('phoneNumber') && !Validators.isValidPhone(data['phoneNumber'])) {
        throw Exception('Invalid phone number in update data');
      }
      
      await _firestore.collection(AppConstants.donorsCollection).doc(uid).update(data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
