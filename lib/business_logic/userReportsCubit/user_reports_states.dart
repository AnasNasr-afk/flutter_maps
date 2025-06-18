abstract class UserReportsStates {}

class UserReportsInitialState extends UserReportsStates {}
class UserReportsLoadedState extends UserReportsStates {
  final List<Map<String, dynamic>> issues;

  UserReportsLoadedState(this.issues);
}
class UserReportsErrorState extends UserReportsStates {}


