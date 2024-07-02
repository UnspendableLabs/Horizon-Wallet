import 'package:flutter_bloc/flutter_bloc.dart';

import "./password_prompt_state.dart";
import "./password_prompt_event.dart";

import "dart:async";

import 'package:rxdart/transformers.dart';

import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

class PasswordPromptBloc
    extends Bloc<PasswordPromptEvent, PasswordPromptState> {
  WalletService walletService;
  WalletRepository walletRepository;
  EncryptionService encryptionService;

  PasswordPromptBloc({
    required this.walletRepository,
    required this.encryptionService,
    required this.walletService,
  }) : super(const PasswordPromptState.initial()) {
    on<Show>(
      (event, emit) async {
        emit(PasswordPromptState.prompt(event.initialGapLimit));
      },
      transformer: debounce(const Duration(milliseconds: 200)),
    );
    on<Reset>(
      (event, emit) async {
        emit(PasswordPromptState.initial(event.gapLimit));
      },
    );
    on<Submit>(
      (event, emit) async {
        emit(const PasswordPromptState.validate());

        try {
          Wallet? wallet = await walletRepository.getCurrentWallet();

          if (wallet == null) {
            throw Exception("invariant: wallet is null");
          }

          String decryptedPrivKey = await encryptionService.decrypt(
              wallet.encryptedPrivKey, event.password);

          Wallet compareWallet = await walletService.fromPrivateKey(
              decryptedPrivKey, wallet.chainCodeHex);

          if (wallet.publicKey != compareWallet.publicKey) {
            throw Exception("invalid password");
          }
          emit(PasswordPromptState.success(event.password, event.gapLimit));
        } catch (e) {
          emit(PasswordPromptState.error(e.toString()));
        }
      },
    );
  }
}

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (Stream<Event> events, Stream<Event> Function(Event) mapper) => events
      .transform(
        StreamTransformer<Event, Event>.fromHandlers(
          handleData: (Event event, EventSink<Event> sink) => sink.add(event),
          handleDone: (EventSink<Event> sink) => sink.close(),
          handleError:
              (Object error, StackTrace stackTrace, EventSink<Event> sink) =>
                  sink.addError(error, stackTrace),
        ),
      )
      .debounceTime(duration)
      .switchMap(mapper);
}
