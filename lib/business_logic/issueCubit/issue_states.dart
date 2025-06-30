
abstract class IssueStates {}

class IssueInitialState extends IssueStates {}

class ImagePickerLoadingState extends IssueStates {}

class ImagePickerSuccessState extends IssueStates {}

class ImagePickerErrorState extends IssueStates {}

class LocationLoadedState extends IssueStates {}

class LocationErrorState extends IssueStates {
  final String error;
  LocationErrorState(this.error);
}

class IssueSubmittingLoadingState extends IssueStates {}
class IssueSubmitSuccessState extends IssueStates {}
class UserReportsLoadedState extends IssueStates {
  List<Map<String, dynamic>> users ;
  UserReportsLoadedState(this.users);
}

class IssueSubmitFailureState extends IssueStates {
  final String error;
  IssueSubmitFailureState(this.error);
}
class UserReportsErrorState extends IssueStates {

}


class UpdateIssueLoadingState extends IssueStates {}

class UpdateIssueSuccessState extends IssueStates {}

class UpdateIssueErrorState extends IssueStates {
  final String errorMessage;

  UpdateIssueErrorState(this.errorMessage);
}

class ResolvedImagePickerLoadingState extends IssueStates {}
class ResolvedImagePickerSuccessState extends IssueStates {}
class ResolvedImagePickerErrorState extends IssueStates {
  final String error;

  ResolvedImagePickerErrorState(this.error);
}

class ImageClearedState extends IssueStates {}


