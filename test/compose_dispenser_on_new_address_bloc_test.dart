import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_chained_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';
import 'package:mocktail/mocktail.dart';

// Import all necessary files and classes
class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockBitcoindService extends Mock implements BitcoindService {}

class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockSignChainedTransactionUseCase extends Mock
    implements SignChainedTransactionUseCase {}

class MockTransactionService extends Mock implements TransactionService {}

class MockFetchDispenseFormDataUseCase extends Mock
    implements FetchDispenseFormDataUseCase {}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class MockVirtualSize extends Mock implements VirtualSize {}

void main() {
  late ComposeDispenserOnNewAddressBloc bloc;
  late MockWalletRepository mockWalletRepository;
  late MockAccountRepository mockAccountRepository;
  late MockAddressRepository mockAddressRepository;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockComposeRepository mockComposeRepository;
  late MockBitcoindService mockBitcoindService;
  late MockUtxoRepository mockUtxoRepository;
  late MockBalanceRepository mockBalanceRepository;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignChainedTransactionUseCase mockSignChainedTransactionUseCase;
  late MockTransactionService mockTransactionService;
  late MockFetchDispenseFormDataUseCase mockFetchDispenseFormDataUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;

  setUpAll(() {
    registerFallbackValue(FeeOption.Medium());
    registerFallbackValue(FormOpened(originalAddress: ''));
    registerFallbackValue(ImportFormat.horizon);
    registerFallbackValue(Account(
      accountIndex: "1'",
      walletUuid: 'wallet-uuid',
      name: 'Dispenser for TestAsset',
      uuid: 'account-uuid',
      purpose: '44',
      coinType: '0',
      importFormat: ImportFormat.horizon,
    ));
    registerFallbackValue(const Address(
      accountUuid: 'account-uuid',
      address: 'address',
      index: 0,
    ));
    registerFallbackValue(Utxo(
      txid: 'txid',
      vout: 0,
      value: 1000,
      address: 'address',
      height: 1,
    ));
    registerFallbackValue(Balance(
      address: 'address',
      asset: 'asset',
      quantity: 1000,
      quantityNormalized: '0.00001000',
      assetInfo: const AssetInfo(
        divisible: true,
        assetLongname: 'TestAsset',
        description: 'description',
      ),
    ));
    registerFallbackValue(ComposeSendResponse(
      rawtransaction: 'rawTx',
      name: 'name',
      btcFee: 1000,
      params: ComposeSendResponseParams(
        destination: 'destination',
        asset: 'asset',
        quantity: 1000,
        source: 'source',
        useEnhancedSend: true,
        assetInfo: const AssetInfo(
          divisible: true,
          assetLongname: 'TestAsset',
          description: 'description',
        ),
        quantityNormalized: '0.00001000',
      ),
    ));
    registerFallbackValue(ComposeDispenserResponse(
      rawtransaction: 'rawTx',
      name: 'name',
      btcFee: 1000,
      params: ComposeDispenserParams(
        source: 'source',
        asset: 'asset',
        giveQuantity: 1000,
        escrowQuantity: 1000,
        mainchainrate: 1,
      ),
    ));
    registerFallbackValue(ComposeSendParams(
      destination: 'destination',
      asset: 'asset',
      quantity: 1000,
      source: 'source',
    ));
    registerFallbackValue(const DecodedTx(
      hash: 'hash',
      txid: 'txid',
      version: 1,
      size: 1,
      vsize: 1,
      weight: 1,
      locktime: 1,
      vin: [
        Vin(
          txid: 'txid',
          vout: 0,
          scriptSig: ScriptSig(asm: 'asm', hex: 'hex'),
          sequence: 1,
          txinwitness: ['witness'],
        )
      ],
      vout: [
        Vout(
          n: 0,
          value: 1000,
          scriptPubKey: ScriptPubKey(
            asm: 'asm',
            hex: 'hex',
            type: 'type',
            desc: 'desc',
          ),
        )
      ],
    ));
  });

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    mockAccountRepository = MockAccountRepository();
    mockAddressRepository = MockAddressRepository();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockComposeRepository = MockComposeRepository();
    mockBitcoindService = MockBitcoindService();
    mockUtxoRepository = MockUtxoRepository();
    mockBalanceRepository = MockBalanceRepository();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignChainedTransactionUseCase = MockSignChainedTransactionUseCase();
    mockTransactionService = MockTransactionService();
    mockFetchDispenseFormDataUseCase = MockFetchDispenseFormDataUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();

    bloc = ComposeDispenserOnNewAddressBloc(
      walletRepository: mockWalletRepository,
      accountRepository: mockAccountRepository,
      addressRepository: mockAddressRepository,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      composeRepository: mockComposeRepository,
      bitcoindService: mockBitcoindService,
      utxoRepository: mockUtxoRepository,
      balanceRepository: mockBalanceRepository,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      signChainedTransactionUseCase: mockSignChainedTransactionUseCase,
      transactionService: mockTransactionService,
      fetchDispenseFormDataUseCase: mockFetchDispenseFormDataUseCase,
      writeLocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('PasswordEntered', () {
    const testPassword = 'test-password';
    const originalAddress = 'original-address';
    const testWallet = Wallet(
      publicKey: 'public-key',
      uuid: 'wallet-uuid',
      name: 'Test Wallet',
      encryptedPrivKey: 'encrypted-private-key',
      chainCodeHex: 'chain-code-hex',
    );
    const decryptedPrivKey = 'decrypted-private-key';
    final oldAccount = Account(
      accountIndex: "0'",
      walletUuid: 'wallet-uuid',
      name: 'Test Account',
      uuid: 'account-uuid',
      purpose: '44',
      coinType: '0',
      importFormat: ImportFormat.horizon,
    );
    final newAccount = Account(
      accountIndex: "1'",
      walletUuid: 'wallet-uuid',
      name: 'Dispenser for TestAsset',
      uuid: 'new-account-uuid',
      purpose: '44',
      coinType: '0',
      importFormat: ImportFormat.horizon,
    );
    const newAddress = Address(
      accountUuid: 'new-account-uuid',
      address: 'new-address',
      index: 0,
    );
    const newAddressPrivKey = 'new-address-private-key';
    final composeSendResponse = ComposeSendResponse(
      rawtransaction: 'rawTx',
      name: 'name',
      btcFee: 1000,
      params: ComposeSendResponseParams(
        destination: newAddress.address,
        asset: 'TestAsset',
        quantity: 1000,
        source: originalAddress,
        useEnhancedSend: true,
        assetInfo: const AssetInfo(
          divisible: true,
          assetLongname: 'TestAsset',
          description: 'description',
        ),
        quantityNormalized: '0.00001000',
      ),
    );
    final composeDispenserResponse = ComposeDispenserResponseVerbose(
      rawtransaction: 'rawTx',
      name: 'name',
      btcFee: 1000,
      btcIn: 1000,
      btcOut: 1000,
      data: 'data',
      params: ComposeDispenserResponseVerboseParams(
        source: newAddress.address,
        asset: 'TestAsset',
        giveQuantity: 1000,
        escrowQuantity: 1000,
        mainchainrate: 1,
        status: 1,
        giveQuantityNormalized: '0.00001000',
        escrowQuantityNormalized: '0.00001000',
      ),
    );
    const signedSendTx = 'signed-send-tx';
    const signedDispenserTx = 'signed-dispenser-tx';

    setUp(() {
      // Mocking methods with argument matchers
      when(() => mockWalletRepository.getCurrentWallet())
          .thenAnswer((_) async => testWallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockAccountRepository.getAccountsByWalletUuid(any()))
          .thenAnswer((_) async => [oldAccount]);
      when(() => mockAddressService.deriveAddressSegwit(
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            purpose: any(named: 'purpose'),
            coin: any(named: 'coin'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            index: any(named: 'index'),
          )).thenAnswer((_) async => newAddress);
      when(() => mockBalanceRepository.getBalancesForAddress(any()))
          .thenAnswer((_) async => []);
      when(() => mockAddressService.deriveAddressPrivateKey(
            rootPrivKey: any(named: 'rootPrivKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            purpose: any(named: 'purpose'),
            coin: any(named: 'coin'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            index: any(named: 'index'),
            importFormat: any(named: 'importFormat'),
          )).thenAnswer((_) async => newAddressPrivKey);
      when(() => mockComposeTransactionUseCase
              .call<ComposeSendParams, ComposeSendResponse>(
            source: any(named: 'source'),
            feeRate: any(named: 'feeRate'),
            params: any(named: 'params'),
            composeFn: any(named: 'composeFn'),
          )).thenAnswer((_) async => (composeSendResponse, MockVirtualSize()));
      when(() => mockComposeRepository.composeDispenserChain(
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => composeDispenserResponse);
      when(() => mockTransactionService.constructChainAndSignTransaction(
            sourceAddress: any(named: 'sourceAddress'),
            unsignedTransaction: any(named: 'unsignedTransaction'),
            utxos: any(named: 'utxos'),
            btcQuantity: any(named: 'btcQuantity'),
            sourcePrivKey: any(named: 'sourcePrivKey'),
            destinationPrivKey: any(named: 'destinationPrivKey'),
            fee: any(named: 'fee'),
          )).thenAnswer((_) async => signedSendTx);
      when(() => mockSignChainedTransactionUseCase.call(
            source: any(named: 'source'),
            rawtransaction: any(named: 'rawtransaction'),
            prevDecodedTransaction: any(named: 'prevDecodedTransaction'),
            addressPrivKey: any(named: 'addressPrivKey'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => signedDispenserTx);
      when(() => mockAccountRepository.insert(any()))
          .thenAnswer((_) async {});
      when(() => mockAddressRepository.insert(any()))
          .thenAnswer((_) async {});
    });

    blocTest<ComposeDispenserOnNewAddressBloc,
        ComposeDispenserOnNewAddressStateBase>(
      'emits CollectPasswordState.loading when processing starts and ConfirmState when processing succeeds',
      build: () => bloc,
      act: (bloc) => bloc.add(
        PasswordEntered(
          status: 1,
          password: testPassword,
          originalAddress: originalAddress,
          divisible: true,
          asset: 'TestAsset',
          giveQuantity: 1000,
          escrowQuantity: 1000,
          mainchainrate: 1,
          feeRate: 1,
        ),
      ),
      expect: () => [
        bloc.state.copyWith(
          composeDispenserOnNewAddressState:
              const ComposeDispenserOnNewAddressState.collectPassword(
            loading: true,
          ),
        ),
        bloc.state.copyWith(
          password: testPassword,
          composeDispenserOnNewAddressState:
              ComposeDispenserOnNewAddressState.confirm(
            composeSendTransaction: composeSendResponse,
            composeDispenserTransaction: composeDispenserResponse,
            newAccountName: newAccount.name,
            newAddress: newAddress.address,
            btcQuantity: 1000,
            feeRate: 1,
          ),
          newAccount: newAccount,
          newAddress: newAddress,
          signedAssetSend: signedSendTx,
          signedDispenser: signedDispenserTx,
        ),
      ],
      verify: (_) {
        verify(() => mockWalletRepository.getCurrentWallet()).called(1);
        verify(() => mockEncryptionService.decrypt(
              testWallet.encryptedPrivKey,
              testPassword,
            )).called(1);
        verify(() =>
                mockAccountRepository.getAccountsByWalletUuid(testWallet.uuid))
            .called(1);
        verify(() => mockAddressService.deriveAddressSegwit(
              privKey: decryptedPrivKey,
              chainCodeHex: testWallet.chainCodeHex,
              accountUuid: any(named: 'accountUuid'),
              purpose: any(named: 'purpose'),
              coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              index: any(named: 'index'),
            )).called(1);
        verify(() =>
                mockBalanceRepository.getBalancesForAddress(newAddress.address))
            .called(1);
        verify(() => mockAddressService.deriveAddressPrivateKey(
              rootPrivKey: decryptedPrivKey,
              chainCodeHex: testWallet.chainCodeHex,
              purpose: oldAccount.purpose,
              coin: oldAccount.coinType,
              account: oldAccount.accountIndex,
              change: '0',
              index: 0,
              importFormat: oldAccount.importFormat,
            )).called(1);
        verify(() => mockComposeTransactionUseCase
                .call<ComposeSendParams, ComposeSendResponse>(
              source: originalAddress,
              feeRate: 1,
              params: any(named: 'params'),
              composeFn: mockComposeRepository.composeSendVerbose,
            )).called(1);
        verify(() => mockComposeRepository.composeDispenserChain(
              any(),
              any(),
              any(),
            )).called(1);
        verify(() => mockTransactionService.constructChainAndSignTransaction(
              sourceAddress: originalAddress,
              unsignedTransaction: composeSendResponse.rawtransaction,
              utxos: [],
              btcQuantity: 1000,
              sourcePrivKey: decryptedPrivKey,
              destinationPrivKey: newAddressPrivKey,
              fee: 1,
            )).called(1);
        verify(() => mockSignChainedTransactionUseCase.call(
              source: newAddress.address,
              rawtransaction: composeDispenserResponse.rawtransaction,
              prevDecodedTransaction: any(named: 'prevDecodedTransaction'),
              addressPrivKey: any(named: 'addressPrivKey'),
              password: testPassword,
            )).called(1);
        verify(() => mockAccountRepository.insert(any())).called(1);
        verify(() => mockAddressRepository.insert(any())).called(1);
      },
    );
  });
}
