import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart' as BitcoinTx;
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_event.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_state.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart' as DecodedTx;

// Mock Classes
class MockTransactionService extends Mock implements TransactionService {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockBitcoindService extends Mock implements BitcoindService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockImportedAddressService extends Mock
    implements ImportedAddressService {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockUnifiedAddressRepository extends Mock
    implements UnifiedAddressRepository {}

void main() {
  late SignPsbtBloc signPsbtBloc;
  late MockTransactionService mockTransactionService;
  late MockBalanceRepository mockBalanceRepository;
  late MockBitcoinRepository mockBitcoinRepository;
  late MockBitcoindService mockBitcoindService;
  late MockWalletRepository mockWalletRepository;
  late MockUnifiedAddressRepository mockUnifiedAddressRepository;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockImportedAddressService mockImportedAddressService;
  late MockAccountRepository mockAccountRepository;

  // Sample Decoded Transactions
  const decodedBuyTransaction = DecodedTx.DecodedTx(
    txid: "txid_buy",
    hash: "txid_buy",
    version: 2,
    size: 155,
    vsize: 155,
    weight: 620,
    locktime: 0,
    vin: [
      DecodedTx.Vin(
        txid: "vin0txid",
        vout: 1,
        scriptSig: DecodedTx.ScriptSig(asm: "", hex: ""),
        sequence: 4294967295,
      ),
      DecodedTx.Vin(
        txid: "vin1txid",
        vout: 0,
        scriptSig: DecodedTx.ScriptSig(asm: "", hex: ""),
        sequence: 4292367295,
      ),
    ],
    vout: [
      DecodedTx.Vout(
        value: 0.00000546,
        n: 0,
        scriptPubKey: DecodedTx.ScriptPubKey(
          asm: "0 asm",
          desc: "addr(address)#type",
          hex: "hex",
          address: "address",
          type: "witness_v0_keyhash",
        ),
      ),
      DecodedTx.Vout(
        value: 0.000006,
        n: 1,
        scriptPubKey: DecodedTx.ScriptPubKey(
          asm: "0 asm",
          desc: "addr(address)#type",
          hex: "hex",
          address: "address",
          type: "witness_v0_keyhash",
        ),
      ),
      DecodedTx.Vout(
        value: 0.00257731,
        n: 2,
        scriptPubKey: DecodedTx.ScriptPubKey(
          asm: "0 7e7a1b5564077c35330bee85a62b689831c346c9",
          desc: "addr(address)#type",
          hex: "hex",
          address: "address",
          type: "witness_v0_keyhash",
        ),
      ),
    ],
  );

  const decodedSellTransaction = DecodedTx.DecodedTx(
    txid: "txid_sell",
    hash: "txid_sell",
    version: 2,
    size: 50,
    vsize: 50,
    weight: 200,
    locktime: 0,
    vin: [
      DecodedTx.Vin(
        txid: "vin0txid_sell",
        vout: 0,
        scriptSig: DecodedTx.ScriptSig(asm: "", hex: ""),
        sequence: 4292355295,
      ),
    ],
    vout: [
      DecodedTx.Vout(
        value: 0.0000055,
        n: 0,
        scriptPubKey: DecodedTx.ScriptPubKey(
          asm: "0 asm",
          desc: "addr(address)#type",
          hex: "hex",
          address: "address",
          type: "witness_v0_keyhash",
        ),
      ),
    ],
  );

  final bitcoinTx = BitcoinTx.BitcoinTx(
    txid: "txid",
    vin: [
      BitcoinTx.Vin(
        txid: "txid",
        vout: 0,
        prevout: BitcoinTx.Prevout(
          scriptpubkey: "hex",
          scriptpubkeyAsm: "",
          scriptpubkeyType: "type",
          value: 546,
          scriptpubkeyAddress: "address",
        ),
        scriptsig: "scriptsig",
        scriptsigAsm: "scriptsigasm",
        witness: [],
        isCoinbase: false,
        sequence: 0,
      ),
      BitcoinTx.Vin(
        txid: "txid",
        vout: 1,
        prevout: BitcoinTx.Prevout(
          scriptpubkey: "hex",
          scriptpubkeyAsm: "",
          scriptpubkeyType: "type",
          value: 56984,
          scriptpubkeyAddress: "address",
        ),
        scriptsig: "scriptsig",
        scriptsigAsm: "scriptsigasm",
        witness: [],
        isCoinbase: false,
        sequence: 0,
      )
    ],
    vout: [
      BitcoinTx.Vout(
        scriptpubkey: "hex",
        scriptpubkeyAsm: "",
        scriptpubkeyType: "type",
        value: 593485,
        scriptpubkeyAddress: "address",
      ),
      BitcoinTx.Vout(
        scriptpubkey: "hex",
        scriptpubkeyAsm: "",
        scriptpubkeyType: "type",
        value: 10000,
        scriptpubkeyAddress: "address",
      )
    ],
    version: 0,
    locktime: 0,
    size: 0,
    weight: 0,
    fee: 0,
    status: BitcoinTx.Status(confirmed: true),
  );

  setUp(() {
    mockTransactionService = MockTransactionService();
    mockBalanceRepository = MockBalanceRepository();
    mockBitcoinRepository = MockBitcoinRepository();
    mockBitcoindService = MockBitcoindService();
    mockWalletRepository = MockWalletRepository();
    mockUnifiedAddressRepository = MockUnifiedAddressRepository();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockImportedAddressService = MockImportedAddressService();
    mockAccountRepository = MockAccountRepository();

    signPsbtBloc = SignPsbtBloc(
      unsignedPsbt: "unsigned_psbt_hex",
      transactionService: mockTransactionService,
      walletRepository: mockWalletRepository,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      importedAddressService: mockImportedAddressService,
      bitcoindService: mockBitcoindService,
      balanceRepository: mockBalanceRepository,
      bitcoinRepository: mockBitcoinRepository,
      addressRepository: mockUnifiedAddressRepository,
      accountRepository: mockAccountRepository,
      signInputs: {
        "address": [0, 1]
      },
      sighashTypes: [1],
    );
  });

  tearDown(() {
    signPsbtBloc.close();
  });

  blocTest<SignPsbtBloc, SignPsbtState>(
    'emits [isFormDataLoaded=true, Success] when FetchFormEvent succeeds with decoded buy transaction',
    build: () {
      when(() => mockTransactionService.psbtToUnsignedTransactionHex(any()))
          .thenReturn("unsigned_transaction_hex");

      when(() => mockBitcoindService.decoderawtransaction(any()))
          .thenAnswer((_) async => decodedBuyTransaction);

      when(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .thenAnswer((_) async => [
                Balance(
                  address: null,
                  quantity: 500000,
                  quantityNormalized: '0.00500000',
                  asset: 'ASSET',
                  utxo:
                      "${decodedBuyTransaction.vin[0].txid}:${decodedBuyTransaction.vin[0].vout}",
                  assetInfo: const AssetInfo(
                    assetLongname: null,
                    description: '',
                    divisible: true,
                  ),
                ),
              ]);

      when(() => mockBitcoinRepository.getTransaction(any()))
          .thenAnswer((_) async => Right(bitcoinTx));

      return signPsbtBloc;
    },
    act: (bloc) => bloc.add(FetchFormEvent()),
    expect: () => [
      isA<SignPsbtState>()
          .having((state) => state.isFormDataLoaded, 'isFormDataLoaded', true)
          .having((state) => state.psbtSignType, 'psbtSignType',
              PsbtSignTypeEnum.buy)
          .having((state) => state.asset, 'asset', 'ASSET')
          .having((state) => state.getAmount, 'getAmount', '0.00500000')
          .having((state) => state.bitcoinAmount, 'bitcoinAmount', 0.000006)
          .having((state) => state.fee, 'fee', 0.00344607),
    ],
    verify: (_) {
      verify(() => mockTransactionService.psbtToUnsignedTransactionHex(any()))
          .called(1);
      verify(() => mockBitcoindService.decoderawtransaction(any())).called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(any())).called(1);
      verify(() => mockBitcoinRepository.getTransaction(any()))
          .called(decodedBuyTransaction.vin.length);
    },
  );

  blocTest<SignPsbtBloc, SignPsbtState>(
    'emits [SignPsbtState.isFormDataLoaded=true, Success] when FetchFormEvent succeeds with decoded sell transaction',
    build: () {
      when(() => mockTransactionService.psbtToUnsignedTransactionHex(any()))
          .thenReturn("unsigned_transaction_hex");

      when(() => mockBitcoindService.decoderawtransaction(any()))
          .thenAnswer((_) async => decodedSellTransaction);

      when(() => mockBalanceRepository.getBalancesForUTXO(any()))
          .thenAnswer((_) async => [
                Balance(
                  address: null,
                  quantity: 300000, // 0.003 BTC
                  quantityNormalized: '0.00300000',
                  asset: 'ASSET',
                  utxo:
                      "${decodedSellTransaction.vin[0].txid}:${decodedSellTransaction.vin[0].vout}",
                  assetInfo: const AssetInfo(
                    assetLongname: null,
                    description: '',
                    divisible: true,
                  ),
                ),
              ]);

      return signPsbtBloc;
    },
    act: (bloc) => bloc.add(FetchFormEvent()),
    expect: () => [
      isA<SignPsbtState>()
          .having((state) => state.isFormDataLoaded, 'isFormDataLoaded', true)
          .having((state) => state.psbtSignType, 'psbtSignType',
              PsbtSignTypeEnum.sell)
          .having((state) => state.asset, 'asset', 'ASSET')
          .having((state) => state.getAmount, 'getAmount', '0.00300000')
          .having((state) => state.bitcoinAmount, 'bitcoinAmount', 0.0000055)
          .having((state) => state.fee, 'fee', 0.0), // Sells do not have a fee
    ],
    verify: (_) {
      verify(() => mockTransactionService.psbtToUnsignedTransactionHex(any()))
          .called(1);
      verify(() => mockBitcoindService.decoderawtransaction(any())).called(1);
      verify(() => mockBalanceRepository.getBalancesForUTXO(any())).called(1);
      verifyNever(() => mockBitcoinRepository.getTransaction(any()));
    },
  );

  blocTest<SignPsbtBloc, SignPsbtState>(
    'emits [SignPsbtState.isFormDataLoaded=true] when FetchFormEvent fails to decode transaction',
    build: () {
      when(() => mockTransactionService.psbtToUnsignedTransactionHex(any()))
          .thenReturn("unsigned_transaction_hex");

      when(() => mockBitcoindService.decoderawtransaction(any()))
          .thenThrow(Exception("Decoding failed"));

      return signPsbtBloc;
    },
    act: (bloc) => bloc.add(FetchFormEvent()),
    expect: () => [
      isA<SignPsbtState>()
          .having((state) => state.isFormDataLoaded, 'isFormDataLoaded', true),
    ],
    verify: (_) {
      verify(() => mockTransactionService.psbtToUnsignedTransactionHex(any()))
          .called(1);
      verify(() => mockBitcoindService.decoderawtransaction(any())).called(1);
    },
  );
}
