import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_maps/business_logic/authCubit/auth_states.dart';

import '../../helpers/app_strings.dart';
import '../../helpers/shared_pref_helper.dart'; // your helper

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(const AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  Future<void> signOut() async {
    emit(const AuthLoading());

    try {
      await FirebaseAuth.instance.signOut();
      await SharedPrefHelper.removeData(userId);
      emit(const AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
