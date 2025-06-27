abstract class UserSecurityStates {}

class UserSecurityInitialState extends UserSecurityStates {}

class ChangePasswordLoadingState extends UserSecurityStates {}

class ChangePasswordSuccessState extends UserSecurityStates {}

class ChangePasswordErrorState extends UserSecurityStates {
  final String error;

  ChangePasswordErrorState(this.error);
}


class DeleteAccountLoadingState extends UserSecurityStates {}

class DeleteAccountSuccessState extends UserSecurityStates {}
class DeleteAccountErrorState extends UserSecurityStates {
  final String error;

  DeleteAccountErrorState(this.error);
}
