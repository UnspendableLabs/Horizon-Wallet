sealed class ViewSeedPhraseState {}

class ViewSeedPhraseInitial extends ViewSeedPhraseState {}

class ViewSeedPhraseLoading extends ViewSeedPhraseState {}

class ViewSeedPhraseError extends ViewSeedPhraseState {
  final String error;
  ViewSeedPhraseError(this.error);
}

class ViewSeedPhraseSuccess extends ViewSeedPhraseState {
  final String seedPhrase;
  ViewSeedPhraseSuccess({required this.seedPhrase});
}
