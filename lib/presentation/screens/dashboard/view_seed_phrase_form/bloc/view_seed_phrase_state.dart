import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_seed_phrase_state.freezed.dart';

@freezed
class ViewSeedPhraseState with _$ViewSeedPhraseState {
  const factory ViewSeedPhraseState.initial(
      ViewSeedPhraseStateInitial initial) = _Initial;
  const factory ViewSeedPhraseState.loading() = _Loading;
  const factory ViewSeedPhraseState.error(String error) = _Error;
  const factory ViewSeedPhraseState.success(
      ViewSeedPhraseStateSuccess succcess) = _Success;
}

@freezed
class ViewSeedPhraseStateInitial with _$ViewSeedPhraseStateInitial {
  const factory ViewSeedPhraseStateInitial({String? error}) =
      _ViewSeedPhraseStateInitial;
}

@freezed
class ViewSeedPhraseStateSuccess with _$ViewSeedPhraseStateSuccess {
  const factory ViewSeedPhraseStateSuccess({
    required String seedPhrase,
  }) = _ViewSeedPhraseStateSuccess;
}
