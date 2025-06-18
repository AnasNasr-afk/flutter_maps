import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/user_model.dart';
import 'signup_states.dart';

class SignupCubit extends Cubit<SignupStates> {
  SignupCubit() : super(SignupInitialState());

  static SignupCubit get(context) => BlocProvider.of(context);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up method
  Future<void> userSignup() async {
    if (!formKey.currentState!.validate()) return;

    emit(SignupLoadingState());
    debugPrint("🌀 State changed: SignupLoadingState");

    try {
      // Firebase Auth: Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // ✅ Set displayName for current user
      await userCredential.user!.updateDisplayName(nameController.text.trim());
      await userCredential.user!.reload();

      // Create user model for Firestore
      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      // Save user to Firestore
      await _firestore.collection("users").doc(user.uid).set(user.toMap());

      emit(SignupSuccessState());
      debugPrint("✅ Emitted SignupSuccessState");

    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuthException: ${e.message}");
      emit(SignupErrorState(e.message));
    } catch (e) {
      debugPrint("❌ Unexpected error: $e");
      emit(SignupErrorState(e.toString()));
    }
  }

}
