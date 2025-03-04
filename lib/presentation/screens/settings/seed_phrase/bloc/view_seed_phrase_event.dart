abstract class ViewSeedPhraseEvent {}

class Submit extends ViewSeedPhraseEvent {
  final String password;
  Submit({required this.password});
}
