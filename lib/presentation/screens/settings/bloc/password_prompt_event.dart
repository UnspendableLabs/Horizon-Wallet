abstract class PasswordPromptEvent {}

class Reset extends PasswordPromptEvent {
  int gapLimit;
  Reset({required this.gapLimit});
}

class Show extends PasswordPromptEvent {
  int initialGapLimit;
  Show({required this.initialGapLimit});
}

class Hide extends PasswordPromptEvent {}

class Submit extends PasswordPromptEvent {
  final String password;
  final int gapLimit;
  Submit({required this.password, required this.gapLimit});
}
