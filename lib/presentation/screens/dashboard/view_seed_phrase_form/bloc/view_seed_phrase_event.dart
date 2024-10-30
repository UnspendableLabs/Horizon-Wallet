abstract class ViewSeedPhraseFormEvent {
  const ViewSeedPhraseFormEvent();
}

class ViewSeedPhrase extends ViewSeedPhraseFormEvent {
  final String password;

  const ViewSeedPhrase({required this.password}) : super();
}
