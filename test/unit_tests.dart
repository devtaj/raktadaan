import 'package:flutter_test/flutter_test.dart';
import 'package:raktadan/core/utils/validators.dart';
import 'package:raktadan/core/utils/error_handler.dart';

void main() {
  group('Validators Tests', () {
    test('validateEmail should return null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), null);
    });

    test('validateEmail should return error for invalid email', () {
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail(''), 'Email is required');
    });

    test('validatePassword should return null for valid password', () {
      expect(Validators.validatePassword('password123'), null);
    });

    test('validatePassword should return error for short password', () {
      expect(Validators.validatePassword('123'), isNotNull);
      expect(Validators.validatePassword(''), 'Password is required');
    });

    test('validateName should return null for valid name', () {
      expect(Validators.validateName('John Doe'), null);
    });

    test('validateName should return error for invalid name', () {
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName(''), 'Name is required');
    });

    test('validatePhone should return null for valid phone', () {
      expect(Validators.validatePhone('+1234567890'), null);
    });

    test('validatePhone should return error for invalid phone', () {
      expect(Validators.validatePhone('123'), isNotNull);
      expect(Validators.validatePhone(''), 'Phone number is required');
    });

    test('isValidBloodGroup should return true for valid blood groups', () {
      expect(Validators.isValidBloodGroup('A+'), true);
      expect(Validators.isValidBloodGroup('O-'), true);
      expect(Validators.isValidBloodGroup('AB+'), true);
    });

    test('isValidBloodGroup should return false for invalid blood groups', () {
      expect(Validators.isValidBloodGroup('X+'), false);
      expect(Validators.isValidBloodGroup(''), false);
    });

    test('isValidId should return true for valid IDs', () {
      expect(Validators.isValidId('user123456'), true);
    });

    test('isValidId should return false for invalid IDs', () {
      expect(Validators.isValidId('123'), false);
      expect(Validators.isValidId(''), false);
    });
  });

  group('ErrorHandler Tests', () {
    test('getFirebaseErrorMessage should return correct message for known codes', () {
      expect(ErrorHandler.getFirebaseErrorMessage('user-not-found'), 
             'No user found with this email.');
      expect(ErrorHandler.getFirebaseErrorMessage('wrong-password'), 
             'Wrong password provided.');
      expect(ErrorHandler.getFirebaseErrorMessage('unknown-error'), 
             'An error occurred. Please try again.');
    });
  });
}