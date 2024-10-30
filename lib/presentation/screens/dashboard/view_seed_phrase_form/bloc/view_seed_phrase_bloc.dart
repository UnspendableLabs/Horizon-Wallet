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

      final wallet = await walletRepository.getCurrentWallet();
      if (wallet == null) {
        emit(const ViewSeedPhraseState.error('Wallet not found'));
        return;
      }

      if (wallet.encryptedMnemonic == null) {
        emit(const ViewSeedPhraseState.error('Wallet mnemonic not found'));
        return;
      }

      final seedPhrase = await encryptionService.decrypt(
          wallet.encryptedMnemonic!, event.password);

      emit(ViewSeedPhraseState.success(
          ViewSeedPhraseStateSuccess(seedPhrase: seedPhrase)));
    });
  }
}
