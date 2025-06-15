import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/data/models/user_model.dart';
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
      debugPrint('✅ Login successful. UID: $uid');

      if (uid != null) {
        await saveToken(uid);
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
