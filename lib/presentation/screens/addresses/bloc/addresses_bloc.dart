import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import "./addresses_state.dart";
import "./addresses_event.dart";

import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';

import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';

import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/domain/repositories/materialized_address_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:rxdart/transformers.dart';
import "dart:async";

class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  WalletRepository walletRepository;
  AccountRepository accountRepository;
  AddressService addressService;
  EncryptionService encryptionService;

  final Map<(Account, int), Address> _cache = {};

  final Map<Account, List<Address>> _data = {};

  AddressesBloc({
    required this.walletRepository,
    required this.accountRepository,
    required this.addressService,
    required this.encryptionService,
  }) : super(const AddressesState.initial()) {
    on<Generate>(
      (event, emit) async {
        emit(const AddressesState.loading());

        try {
          Account? account =
              await accountRepository.getAccountByUuid(event.accountUuid);

          if (account == null) {
            throw Exception("invariant: account not found");
          }

          List<Address> addresses = [];

          Wallet? wallet = await walletRepository.getCurrentWallet();

          if (wallet == null) {
            throw Exception("invariant: wallet is null");
          }

          String decryptedPrivKey = await encryptionService.decrypt(
              wallet.encryptedPrivKey, "UXGmJfeqoLXKGKk9tdk26hQvwIRpI6vm");

          for (int i = 0; i < event.gapLimit; i++) {
            if (_cache.containsKey((account, i))) {
              addresses.add(_cache[(account, i)]!);
              continue;
            }

            Address address = await addressService.deriveAddressSegwit(
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account.uuid,
                purpose: account.purpose,
                coin: account.coinType,
                account: account.accountIndex,
                change: "0",
                index: i);

            _cache[(account, i)] = address;

            addresses.add(address);
          }

          _data[account] = addresses;

          emit(AddressesState.success(addresses));
        } catch (e) {
          emit(AddressesState.error(e.toString()));
        }
      },
      transformer: debounce(const Duration(milliseconds: 200)),
    );

  }
}


EventTransformer<Event> debounce<Event>(Duration duration) {
  return (Stream<Event> events, Stream<Event> Function(Event) mapper) => events
      .transform(
        StreamTransformer<Event, Event>.fromHandlers(
          handleData: (Event event, EventSink<Event> sink) => sink.add(event),
          handleDone: (EventSink<Event> sink) => sink.close(),
          handleError: (Object error, StackTrace stackTrace, EventSink<Event> sink) => sink.addError(error, stackTrace),
        ),
      )
      .debounceTime(duration)
      .switchMap(mapper);
}
