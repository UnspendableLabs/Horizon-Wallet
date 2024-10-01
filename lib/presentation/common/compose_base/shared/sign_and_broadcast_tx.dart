import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:logger/logger.dart';

Future<void> signAndBroadcastTransaction<T, S extends ComposeStateBase>({
  required S state,
  required Emitter<S> emit,
  required String password,
  required AddressRepository addressRepository,
  required AccountRepository accountRepository,
  required WalletRepository walletRepository,
  required UtxoRepository utxoRepository,
  required EncryptionService encryptionService,
  required AddressService addressService,
  required TransactionService transactionService,
  required BitcoindService bitcoindService,
  required ComposeRepository composeRepository,
  required TransactionRepository transactionRepository,
  required TransactionLocalRepository transactionLocalRepository,
  required AnalyticsService analyticsService,
  required Logger logger,
  required Function() extractParams,
  required Function(String, String, String?, String?, int?, String?)
      successAction,
}) async {
  if (state.submitState is! SubmitFinalizing<T>) {
    return;
  }

  final params = (state.submitState as SubmitFinalizing<T>).composeTransaction;
  final fee = (state.submitState as SubmitFinalizing<T>).fee;

  emit((state as dynamic).copyWith(
    submitState: SubmitFinalizing<T>(
      loading: true,
      error: null,
      composeTransaction: params,
      fee: fee,
    ),
  ) as S);

  late String source;
  late String rawTx;
  late String destination;
  late int quantity;
  late String asset;

  (source, rawTx, destination, quantity, asset) = extractParams();

  try {
    final utxos = await utxoRepository.getUnspentForAddress(source);
    Map<String, Utxo> utxoMap = {for (var e in utxos) e.txid: e};

    Address? address = await addressRepository.getAddress(source);
    Account? account =
        await accountRepository.getAccountByUuid(address!.accountUuid);
    Wallet? wallet = await walletRepository.getWallet(account!.walletUuid);

    String? decryptedRootPrivKey;
    try {
      decryptedRootPrivKey =
          await encryptionService.decrypt(wallet!.encryptedPrivKey, password);
    } catch (e) {
      throw Exception("Incorrect password");
    }

    String addressPrivKey = await addressService.deriveAddressPrivateKey(
        rootPrivKey: decryptedRootPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        purpose: account.purpose,
        coin: account.coinType,
        account: account.accountIndex,
        change: '0',
        index: address.index,
        importFormat: account.importFormat);

    String txHex = await transactionService.signTransaction(
        rawTx, addressPrivKey, source, utxoMap);
    String txHash = await bitcoindService.sendrawtransaction(txHex);

    await successAction(txHex, txHash, source, destination, quantity, asset);
  } catch (error) {
    emit((state as dynamic).copyWith(
      submitState: SubmitFinalizing<T>(
        loading: false,
        error: error.toString(),
        composeTransaction: params,
        fee: fee,
      ),
    ) as S);
  }
}
