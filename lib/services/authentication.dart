import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_final/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reset(String email) async {
    try {
      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'Please provide an email address.',
        );
      }
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> sendCode(String phoneNumber) async {
    Completer<String?> completer = Completer<String?>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+880$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          completer.complete(null);
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );
      return await completer.future;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> verifyOtp(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication failed: Tokens are null');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _firebaseAuth.signInWithCredential(
        credential,
      );
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        final Database database = Database(uid: user.uid);
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (!userDoc.exists) {
          // User doesn't exist, create their data
          await database.createUser(
            googleUser.displayName ?? "Google User", // Use Google display name
            googleUser.email, // Use Google email
            false, // Provide the missing argument (e.g., isStudent as false)
          );
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<User?> signUp(
    String email,
    String password,
    String name,
    bool isStudent,
  ) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await Database(uid: result.user!.uid).createUser(name, email, isStudent);
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  User? get user => _firebaseAuth.currentUser;

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
