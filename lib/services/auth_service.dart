import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:fashion_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _verificationId;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ───────────────── OTP AUTH ─────────────────

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function() onAutoVerified,
  }) async {
    try {
      if (kIsWeb) {
        // WEB implementation
        final confirmationResult =
            await _auth.signInWithPhoneNumber(phoneNumber);

        _verificationId = confirmationResult.verificationId;

        onCodeSent(_verificationId!);
      } else {
        // ANDROID / IOS implementation
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),

          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);

            await _createOrUpdateUserDoc(
              _auth.currentUser!,
              phoneNumber,
            );

            onAutoVerified();
          },

          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? "Verification failed");
          },

          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            onCodeSent(verificationId);
          },

          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // ───────────────── VERIFY OTP ─────────────────

  Future<UserCredential> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw Exception("Verification ID is null. Request OTP first.");
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    final userCred = await _auth.signInWithCredential(credential);

    await _createOrUpdateUserDoc(
      userCred.user!,
      userCred.user!.phoneNumber ?? '',
    );

    return userCred;
  }

  // ───────────────── CREATE USER DOC ─────────────────

  Future<void> _createOrUpdateUserDoc(User user, String phone) async {
    final ref = _db.collection('users').doc(user.uid);

    final snap = await ref.get();

    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'phone': phone,
        'wishlist': [],
        'fcm_token': fcmToken,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'fcm_token': fcmToken,
      });
    }
  }

  // ───────────────── ADMIN LOGIN ─────────────────

  Future<bool> adminLogin(String username, String password) async {
    try {
      final hash = sha256.convert(utf8.encode(password)).toString();

      final query = await _db
          .collection('admin')
          .where('username', isEqualTo: username)
          .where('password_hash', isEqualTo: hash)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('admin_id', query.docs.first.id);

        await prefs.setString(
            'admin_name', query.docs.first['name'] ?? 'Admin');

        await prefs.setBool('is_admin', true);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  Future<void> adminLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ───────────────── SIGN OUT ─────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ───────────────── USER PROFILE ─────────────────

  Future<UserModel?> getUserProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();

    if (!snap.exists) return null;

    return UserModel.fromMap(snap.data()!);
  }

  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(uid).update(data);
  }
}