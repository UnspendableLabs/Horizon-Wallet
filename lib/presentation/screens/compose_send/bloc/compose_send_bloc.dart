import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_event.dart';
import 'package:horizon/presentation/screens/compose_send/bloc/compose_send_state.dart';

class ComposeSendBloc extends Bloc<ComposeSendEvent, ComposeSendState> {
  ComposeSendBloc() : super(ComposeSendInitial()) {
    on<SendTransactionEvent>((event, emit) async => _onSendTransactionEvent(event, emit));
  }
}

_onSendTransactionEvent(SendTransactionEvent event, emit) async {
  final composeRepository = GetIt.I.get<ComposeRepository>();
  final utxoRepository = GetIt.I.get<UtxoRepository>();
  final transactionService = GetIt.I.get<TransactionService>();
  final bitcoindService = GetIt.I.get<BitcoindService>();
  final accountRepository = GetIt.I.get<AccountRepository>();
  final walletRepository = GetIt.I.get<WalletRepository>();
  final encryptionService = GetIt.I.get<EncryptionService>();
  final addressService = GetIt.I.get<AddressService>();

  emit(ComposeSendLoading());

  try {
    final source = event.sourceAddress;
    final destination = event.destinationAddress;
    final quantity = event.quantity;
    final asset = event.asset;
    final password = event.password;
    // final memo = event.memo;
    // final memoIsHex = event.memoIsHex;

    final rawTx = await composeRepository.composeSend(source.address, destination, asset, quantity, true, 167);

    final utxoResponse = await utxoRepository.getUnspentForAddress(event.sourceAddress.address);

    Map<String, Utxo> utxoMap = {for (var e in utxoResponse) e.txid: e};

    Account? account = await accountRepository.getAccountByUuid(source.accountUuid);
    Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);
    String decryptedRootPrivKey = await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
    String addressPrivKey = await addressService.deriveAddressPrivateKey(
        rootPrivKey: decryptedRootPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        purpose: account.purpose,
        coin: account.coinType,
        account: account.accountIndex,
        change: '0', // TODO make sure change is stored
        index: source.index);

    String txHex = await transactionService.signTransaction(rawTx.hex, addressPrivKey, event.sourceAddress.address, utxoMap);
    print('TXHEX!: $txHex');
    await bitcoindService.sendrawtransaction(txHex);

    emit(ComposeSendSuccess(transactionHex: txHex, sourceAddress: source.address));
  } catch (error, stackTrace) {
    if (error is DioException) {
      emit(ComposeSendError(message: "${error.response!.data.keys.first} ${error.response!.data.values.first}"));
    } else {
      emit(ComposeSendError(message: error.toString()));
    }
  }
}
