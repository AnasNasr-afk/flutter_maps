import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class IssueSubmittingState extends IssueStates {}
class IssueSubmitSuccessState extends IssueStates {}
class IssueSubmitFailureState extends IssueStates {
  final String error;
  IssueSubmitFailureState(this.error);
}





