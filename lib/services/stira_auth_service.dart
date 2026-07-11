import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'local_storage.dart';
import 'cloud_sync_service.dart';
import 'auth_service.dart';


class StiraAuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  User? getCurrentUser() => _auth.currentUser;
  Stream<User?> get authStateStream => _auth.authStateChanges();

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.failure('cancelled');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCred = await _auth.signInWithCredential(credential);
      final User user = userCred.user!;
      final bool isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      await _upsertUserDocument(user, isNew: isNew);

      // Always clear guest mode when a real account signs in
      await StorageService().setGuestMode(false);

      bool completedOnboarding = false;
      if (!isNew) {
        final firestoreOnboarded = await checkOnboardingComplete(user.uid);
        if (firestoreOnboarded) {
          completedOnboarding = true;
          final storage = StorageService();
          await storage.setOnboardingCompleted();
          final doc = await _db.collection('users').doc(user.uid).get();
          final profileData = doc.data()?['profile'] as Map<String, dynamic>?;
          if (profileData != null) {
            await storage.saveProfile(profileData);
          } else {
            await storage.saveProfile({'name': user.displayName ?? ''});
          }
        }
      } else {
        // New user: save displayName to local storage immediately so profile shows name
        final storage = StorageService();
        final name = user.displayName ?? '';
        if (name.isNotEmpty) {
          await storage.saveProfile({'name': name});
        }
      }

      // Sync local stats and history to Firebase Firestore immediately upon successful sign-in
      try {
        final syncService = CloudSyncService(
          _db,
          AuthService(_auth),
          StorageService(),
        );
        await syncService.syncHistoryToCloud();
      } catch (syncErr) {
        debugPrint('Post-login automatic CloudSync failed: $syncErr');
      }

      return AuthResult.success(user, isNewUser: isNew && !completedOnboarding);

    } on FirebaseAuthException catch (e) {
      debugPrint('StiraAuth Google error [${e.code}]: ${e.message}');
      return AuthResult.failure(_mapAuthError(e.code));
    } catch (e) {
      final msg = e.toString();
      if (kDebugMode) debugPrint('StiraAuth Google unexpected error: $msg');
      // API Exception 10 means the SHA-1 fingerprint or OAuth client is
      // misconfigured in the Firebase Console — never silently fall back
      // to anonymous auth, as that creates orphaned ghost accounts.
      if (msg.contains(': 10') || msg.contains('ApiException: 10') || msg.contains('DEVELOPER_ERROR')) {
        return AuthResult.failure(
          'Google sign-in is not set up correctly on this device.\n'
          'Please check your internet connection and try again.',
        );
      }
      return AuthResult.failure('Google sign-in failed. Please try again.');
    }
  }

  Future<void> continueAsGuest() async {
    await StorageService().setGuestMode(true);
  }

  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await StorageService().setGuestMode(false);
    } catch (e) {
      debugPrint('StiraAuth logout error: $e');
    }
  }

  Future<DeleteResult> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return DeleteResult.failure('No authenticated user found.');
    try {
      await StorageService().clearAll();
      await _deleteFirestoreUserData(user.uid);
      await _reauthenticateForDeletion();
      await user.delete();
      return DeleteResult.success();
    } on FirebaseAuthException catch (e) {
      debugPrint('StiraAuth delete account error [${e.code}]: ${e.message}');
      if (e.code == 'requires-recent-login') {
        return DeleteResult.failure('For security, please sign out and sign back in before deleting your account.');
      }
      return DeleteResult.failure(_mapAuthError(e.code));
    } catch (e) {
      debugPrint('StiraAuth delete account unexpected error: $e');
      return DeleteResult.failure('Account deletion failed. Please try again.');
    }
  }

  Future<void> _reauthenticateForDeletion() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } catch (e) {
      debugPrint('StiraAuth re-auth error: $e');
    }
  }

  Future<void> _deleteFirestoreUserData(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      debugPrint('StiraAuth: Firestore document deleted for $uid');
    } catch (e) {
      debugPrint('StiraAuth: Firestore delete failed: $e');
    }
  }

  Future<void> _upsertUserDocument(User user, {required bool isNew}) async {
    final docRef = _db.collection('users').doc(user.uid);
    if (isNew) {
      final existing = await docRef.get();
      if (!existing.exists) {
        await docRef.set(_buildInitialProfile(user));
        debugPrint('StiraAuth: Created new Firestore profile for ${user.uid}');
        return;
      }
    }
    await docRef.set({
      'last_login': FieldValue.serverTimestamp(),
      'photoUrl': user.photoURL,
    }, SetOptions(merge: true));
    debugPrint('StiraAuth: Updated last_login for ${user.uid}');
  }

  Map<String, dynamic> _buildInitialProfile(User user) {
    return {
      'uid': user.uid,
      'displayName': user.displayName ?? 'Friend',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'role': 'user',
      'accountStatus': 'active',
      'subscriptionPlan': 'free',
      'created_at': FieldValue.serverTimestamp(),
      'last_login': FieldValue.serverTimestamp(),
      'last_sync': FieldValue.serverTimestamp(),
      'onboarding_complete': false,
      'fcm_token': '',
      'current_streak': 0,
      'longest_streak': 0,
      'total_clean_days': 0,
      'streak_insurance_available': 0,
      'bond_partner_uid': null,
      'profile': null,
    };
  }

  Future<void> completeOnboarding({
    required String uid,
    required Map<String, dynamic> assessmentData,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'onboarding_complete': true,
        'profile': assessmentData,
      }, SetOptions(merge: true));
      debugPrint('StiraAuth: Onboarding marked complete for $uid');
    } catch (e) {
      debugPrint('StiraAuth: completeOnboarding error: $e');
    }
  }

  Future<bool> checkOnboardingComplete(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      return (doc.data()?['onboarding_complete'] as bool?) ?? false;
    } catch (e) {
      debugPrint('StiraAuth: checkOnboardingComplete error: $e');
      return StorageService().onboardingCompleted;
    }
  }

  String _mapAuthError(String code) => switch (code) {
    'account-exists-with-different-credential' => 'An account with this email already exists using a different sign-in method.',
    'network-request-failed' => 'Network error. Please check your connection.',
    'too-many-requests' => 'Too many attempts. Please wait before trying again.',
    'user-disabled' => 'This account has been disabled.',
    'operation-not-allowed' => 'Google sign-in is not enabled.',
    _ => 'Authentication failed. Please try again. ($code)',
  };
}

class AuthResult {
  final bool success;
  final User? user;
  final String errorMessage;
  final bool isNewUser;

  const AuthResult._({
    required this.success,
    this.user,
    this.errorMessage = '',
    this.isNewUser = false,
  });

  factory AuthResult.success(User u, {bool isNewUser = false}) =>
      AuthResult._(success: true, user: u, isNewUser: isNewUser);

  factory AuthResult.failure(String msg) =>
      AuthResult._(success: false, errorMessage: msg);

  bool get wasCancelled => errorMessage == 'cancelled';
}

class DeleteResult {
  final bool success;
  final String errorMessage;

  const DeleteResult._({required this.success, this.errorMessage = ''});

  factory DeleteResult.success() => const DeleteResult._(success: true);
  factory DeleteResult.failure(String msg) =>
      DeleteResult._(success: false, errorMessage: msg);
}