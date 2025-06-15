import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      emit(LoginSuccessState());
    } catch (e) {
      emit(LoginErrorState());
    }
  }


}
