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

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      debugPrint("✅ User created: ${user.uid}");
      debugPrint("📝 Saving user to Firestore...");
      debugPrint("📌 User data to save: ${user.toMap()}");

      // Save to Firestore
      await _firestore.collection("users").doc(user.uid).set(user.toMap());

      debugPrint("✅ Firestore save complete");

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
