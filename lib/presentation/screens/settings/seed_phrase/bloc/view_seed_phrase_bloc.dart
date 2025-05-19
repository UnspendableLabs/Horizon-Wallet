import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_state.dart';
import 'package:horizon/domain/repositories/mnemonic_repository.dart';
import "package:fpdart/fpdart.dart";

class ViewSeedPhraseBloc
    extends Bloc<ViewSeedPhraseEvent, ViewSeedPhraseState> {
  final EncryptionService _encryptionService;

  final MnemonicRepository _mnemonicRepository;

  ViewSeedPhraseBloc({
    MnemonicRepository? mnemonicRepository,
    EncryptionService? encryptionService,
  })  : _mnemonicRepository =
            mnemonicRepository ?? GetIt.I<MnemonicRepository>(),
        _encryptionService = encryptionService ?? GetIt.I<EncryptionService>(),
        super(ViewSeedPhraseInitial()) {
    on<Submit>((event, emit) async {
      emit(ViewSeedPhraseLoading());

      final task = TaskEither<String, String>.Do(($) async {
        final encryptedMnemonic = await $(_mnemonicRepository
            .getT(
              onError: (error_, stacktrace_) =>
                  'invariant: error reading mnemonic',
            )
            .flatMap((mnemonic) => TaskEither.fromOption(
                mnemonic, () => "invariant: mnemonic is null")));

        final mnemonic = await $(_encryptionService.decryptT(
            data: encryptedMnemonic,
            password: event.password,
            onError: (error_, stacktrace_) => 'invalid password'));

        return mnemonic;
      });

      final result = await task.run();

      result.fold(
        (error) {
          emit(ViewSeedPhraseError(error));
        },
        (mnemonic) {
          emit(ViewSeedPhraseSuccess(seedPhrase: mnemonic));
        },
      );
    });
  }
}
