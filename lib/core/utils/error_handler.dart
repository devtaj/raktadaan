import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'permission-denied':
        return 'Permission denied. Please check your access rights.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getFirebaseErrorMessage(error.code);
    }
    if (error is FirebaseException) {
      return getFirebaseErrorMessage(error.code);
    }
    return error.toString();
  }

  static Exception handleError(dynamic error) {
    return Exception(getErrorMessage(error));
  }
}