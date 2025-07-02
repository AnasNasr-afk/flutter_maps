
abstract class UserReportsStates {}

class UserReportsInitialState extends UserReportsStates {}

class UserReportsLoadingState extends UserReportsStates {}

class UserReportsLoadedState extends UserReportsStates {
  final List<Map<String, dynamic>> issues;
  final bool isAdmin;
  UserReportsLoadedState({required this.issues, required this.isAdmin});
}

class UserReportsErrorState extends UserReportsStates {
  final String? message;
  UserReportsErrorState({this.message});
}