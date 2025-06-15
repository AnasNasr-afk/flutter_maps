abstract class SignupStates {}


class SignupInitialState extends SignupStates {}

class SignupSuccessState extends SignupStates {}

class SignupErrorState extends SignupStates {
  final String? errorMessage;

  SignupErrorState(this.errorMessage);
}

class SignupLoadingState extends SignupStates {}
