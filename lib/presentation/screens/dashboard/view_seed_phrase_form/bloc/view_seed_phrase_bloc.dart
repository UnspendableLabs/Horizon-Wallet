import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/bloc/view_seed_phrase_state.dart';

class ViewSeedPhraseBloc
    extends Bloc<ViewSeedPhraseEvent, ViewSeedPhraseState> {
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;

  ViewSeedPhraseBloc({
    required this.walletRepository,
    required this.encryptionService,
  }) : super(ViewSeedPhraseInitial()) {
    on<Submit>((event, emit) async {
      emit(ViewSeedPhraseLoading());
      try {
        final wallet = await walletRepository.getCurrentWallet();
        if (wallet == null) {
          emit(ViewSeedPhraseError('Wallet not found'));
          return;
        }

        if (wallet.encryptedMnemonic == null) {
          emit(ViewSeedPhraseError('Wallet mnemonic not found'));
          return;
        }

        try {
          final seedPhrase = await encryptionService.decrypt(
            wallet.encryptedMnemonic!,
            event.password,
          );
          emit(ViewSeedPhraseSuccess(seedPhrase: seedPhrase));
        } catch (e) {
          emit(ViewSeedPhraseError('Invalid password'));
        }
      } catch (e) {
        emit(ViewSeedPhraseError('Error decrypting seed phrase'));
      }
    });
  }
}
