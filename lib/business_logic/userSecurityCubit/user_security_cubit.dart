import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/userSecurityCubit/user_security_states.dart';
import 'package:flutter_maps/helpers/shared_pref_helper.dart';

import '../../helpers/app_strings.dart';

class UserSecurityCubit extends Cubit<UserSecurityStates> {
  UserSecurityCubit() : super(UserSecurityInitialState());

  static UserSecurityCubit get(context) => BlocProvider.of(context);

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // 🔐 Change password
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      emit(ChangePasswordErrorState('Passwords do not match.'));
      return;
    }

    emit(ChangePasswordLoadingState());

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        emit(
            ChangePasswordErrorState('User not logged in or email not found.'));
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      await SharedPrefHelper.removeData(userId);
      emit(ChangePasswordSuccessState());
    } catch (e) {
      emit(ChangePasswordErrorState('Error: ${e.toString()}'));
    }
  }

  // ❌ Delete account
  Future<void> reauthenticateAndDelete(String password) async {
    emit(DeleteAccountLoadingState());

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        emit(DeleteAccountErrorState('User not logged in.'));
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // 🔐 Re-authenticate
      await user.reauthenticateWithCredential(cred);

      // 🗑️ Delete
      await user.delete();

      // 🧹 Clean up local data
      await SharedPrefHelper.removeData(userId);

      emit(DeleteAccountSuccessState());
    } on FirebaseAuthException catch (e) {
      String error = e.code == 'wrong-password'
          ? 'Incorrect password'
          : (e.message ?? 'Reauthentication failed.');
      emit(DeleteAccountErrorState(error));
    } catch (e) {
      emit(DeleteAccountErrorState('Unexpected error: ${e.toString()}'));
    }
  }



}
