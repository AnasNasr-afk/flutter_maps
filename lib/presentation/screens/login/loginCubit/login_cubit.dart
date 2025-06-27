import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/helpers/app_strings.dart';
import 'package:flutter_maps/helpers/shared_pref_helper.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(InitialLoginState());

  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> userLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    emit(LoginLoadingState());

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      debugPrint('🔐 Attempting login with email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      final username = credential.user?.displayName ?? 'User';

      if (uid != null) {
        // 🔐 Store UID in local storage
        await SharedPrefHelper.setData(userId, uid);

        String? token;

        if (Platform.isIOS) {
          // ✅ Wait for APNs token (iOS only)
          String? apnsToken;
          int retries = 10;
          while (apnsToken == null && retries-- > 0) {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            await Future.delayed(const Duration(milliseconds: 500));
          }

          if (apnsToken != null) {
            token = await FirebaseMessaging.instance.getToken();
          } else {
            debugPrint('❌ Could not retrieve APNs token.');
          }
        } else {
          // ✅ Android FCM token
          token = await FirebaseMessaging.instance.getToken();
        }

        // ✅ Save FCM token to Firestore
        if (token != null && token.isNotEmpty) {
          debugPrint('📱 Android FCM token: $token'); // ADD THIS
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({'fcmToken': token}, SetOptions(merge: true));
        }
        else {
          debugPrint('⚠️ No FCM token available');
        }

        emit(LoginSuccessState());
      } else {
        debugPrint('⚠️ Login succeeded but UID is null');
        emit(LoginErrorState());
      }
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      emit(LoginErrorState());
    }
  }



Future<void> saveToken(String token) async {
    await SharedPrefHelper.setData(userId, token);
  }



}
