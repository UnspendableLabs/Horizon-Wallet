import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_state.dart';

class ViewSeedPhraseBloc
    extends Bloc<ViewSeedPhraseFormEvent, ViewSeedPhraseState> {
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  ViewSeedPhraseBloc({
    required this.walletRepository,
    required this.encryptionService,
  }) : super(const ViewSeedPhraseState.initial(ViewSeedPhraseStateInitial())) {
    on<ViewSeedPhrase>((event, emit) async {
      emit(const ViewSeedPhraseState.loading());
      try {
        final wallet = await walletRepository.getCurrentWallet();
        if (wallet == null) {
          emit(const ViewSeedPhraseState.initial(
              ViewSeedPhraseStateInitial(error: 'Wallet not found')));
          return;
        }

        if (wallet.encryptedMnemonic == null) {
          emit(const ViewSeedPhraseState.initial(
              ViewSeedPhraseStateInitial(error: 'Wallet mnemonic not found')));
          return;
        }

        String seedPhrase;
        try {
          seedPhrase = await encryptionService.decrypt(
              wallet.encryptedMnemonic!, event.password);
        } catch (e) {
          emit(const ViewSeedPhraseState.initial(
              ViewSeedPhraseStateInitial(error: 'Invalid password')));
          return;
        }

        emit(ViewSeedPhraseState.success(
            ViewSeedPhraseStateSuccess(seedPhrase: seedPhrase)));
      } catch (e) {
        emit(const ViewSeedPhraseState.error('Error decrypting seed phrase'));
      }
    });
  }
}
