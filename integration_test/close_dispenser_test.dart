import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/close_dispenser/view/close_dispenser_page.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:mocktail/mocktail.dart';

import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_virtual_size_usecase.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_response.dart';

class FakeVirtualSize extends Fake implements VirtualSize {
  @override
  final int virtualSize;
  @override
  final int adjustedVirtualSize;

  FakeVirtualSize(
      {required this.virtualSize, required this.adjustedVirtualSize});
}

class FakeDispenser extends Fake implements Dispenser {
  final String _asset;
  final int _giveQuantity;
  final String _giveQuantityNormalized;
  final int _satoshirate;
  final String _satoshirateNormalized;
  // final int _giveRemaining;
  // final AssetInfo _assetInfo;
  final String _source;
  final int _escrowQuantity;
  final int _status;

  FakeDispenser(
      {required String asset,
      required int giveQuantity,
      required int satoshirate,
      // required int giveRemaining,
      // required AssetInfo assetInfo,
      required String source,
      required int escrowQuantity,
      required int status,
      required String giveQuantityNormalized,
      required String satoshirateNormalized})
      : _asset = asset,
        _giveQuantity = giveQuantity,
        _giveQuantityNormalized = giveQuantityNormalized,
        _satoshirate = satoshirate,
        _satoshirateNormalized = satoshirateNormalized,
        // _giveRemaining = giveRemaining,
        // _assetInfo = assetInfo,
        _source = source,
        _escrowQuantity = escrowQuantity,
        _status = status;

  @override
  String get asset => _asset;

  @override
  int get giveQuantity => _giveQuantity;

  @override
  String get giveQuantityNormalized => _giveQuantityNormalized;

  @override
  int get satoshirate => _satoshirate;

  @override
  String get satoshirateNormalized => _satoshirateNormalized;
  // @override
  // int get giveRemaining => _giveRemaining;
  // //
  // @override
  // AssetInfo get assetInfo => _assetInfo;

  @override
  String get source => _source;

  @override
  int get escrowQuantity => _escrowQuantity;

  @override
  String get escrowQuantityNormalized => "escrow-quantity-normalized";

  @override
  int get status => _status;
}

class FakeComposeDispenserResponseVerbose extends Fake
    implements ComposeDispenserResponseVerbose {
  final int _btcFee;

  FakeComposeDispenserResponseVerbose({required int btcFee}) : _btcFee = btcFee;

  @override
  int get btcFee => _btcFee;
}

class MockComposeTransactionUseCase extends Mock
    implements ComposeTransactionUseCase {}

class MockFetchCloseDispenserFormDataUseCase extends Mock
    implements FetchCloseDispenserFormDataUseCase {}

// {required String password,
// // todo: no reason to have extrat params...just pass in dirctly.
// required Function(String, String) onSuccess,
// required Function(String) onError,
// required String source,
// required String rawtransaction}) async {

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {
  @override
  Future<void> call({
    required String password,
    required Function(
      String,
      String,
    ) onSuccess,
    required Function(String) onError,
    required String source,
    required String rawtransaction,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #call,
        [],
        {
          #password: password,
          #onSuccess: onSuccess,
          #onError: onError,
        },
      ),
    );
  }
}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockComposeDispenserEventParams extends Mock
    implements ComposeDispenserEventParams {
  @override
  String get asset => 'ASSET_NAME';

  @override
  int get giveQuantity => 1000;

  @override
  int get escrowQuantity => 500;

  @override
  int get mainchainrate => 1;

  @override
  int get status => 0;

  @override
  String get openAddress => 'test-address';

  @override
  String get oracleAddress => 'test-oracle-address';
}

class MockComposeDispenserResponseVerboseParams extends Mock
    implements ComposeDispenserResponseVerboseParams {}

class MockComposeDispenserVerbose extends Mock
    implements ComposeDispenserResponseVerbose {}

class MockDashboardActivityFeedBloc extends Mock
    implements DashboardActivityFeedBloc {}

class MockGetVirtualSizeUseCase extends Mock implements GetVirtualSizeUseCase {}

class MockSessionStateCubit extends Mock implements SessionStateCubit {
  @override
  SessionState get state => const SessionState.success(SessionStateSuccess(
        accounts: [],
        redirect: false,
        decryptionKey: "decryption_key",
        wallet: Wallet(
          name: 'Test Wallet',
          uuid: 'test-wallet-uuid',
          publicKey: '',
          encryptedPrivKey: '',
          chainCodeHex: '',
        ),
        currentAccountUuid: 'test-account-uuid',
        addresses: [],
        currentAddress: Address(
          address: 'test-address',
          accountUuid: 'test-account-uuid',
          index: 0,
        ),
      ));
}

class MockWriteLocalTransactionUseCase extends Mock
    implements WriteLocalTransactionUseCase {}

class FakeComposeDispenserParams extends Fake
    implements ComposeDispenserParams {}

class FakeAssetInfo extends Fake implements AssetInfo {
  final bool _divisible;

  FakeAssetInfo({required bool divisible}) : _divisible = divisible;

  @override
  bool get divisible => _divisible;
}

class FakeAddress extends Fake implements Address {
  @override
  String get address => 'test-address';

  @override
  String get accountUuid => 'test-account-uuid';

  @override
  int get index => 0;
}

class FakeUtxo extends Fake implements Utxo {}

class FakeComposeFunction<T extends ComposeResponse> extends Fake {
  Future<T> call(int fee, List<Utxo> inputsSet) async {
    throw UnimplementedError("asdfasfd");
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late CloseDispenserBloc closeDispenserBloc;
  late MockDashboardActivityFeedBloc mockDashboardActivityFeedBloc;

  late ComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockFetchCloseDispenserFormDataUseCase
      mockFetchCloseDispenserFormDataUseCase;
  late MockSignAndBroadcastTransactionUseCase
      mockSignAndBroadcastTransactionUseCase;
  late MockAnalyticsService mockAnalyticsService;
  late MockComposeRepository mockComposeRepository;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;

  setUpAll(() {
    registerFallbackValue(FakeAddress().address);
    registerFallbackValue(
        FakeComposeFunction<ComposeDispenserResponseVerbose>());
    registerFallbackValue(FakeComposeDispenserParams());
  });

  setUp(() {
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockFetchCloseDispenserFormDataUseCase =
        MockFetchCloseDispenserFormDataUseCase();
    mockSignAndBroadcastTransactionUseCase =
        MockSignAndBroadcastTransactionUseCase();
    mockAnalyticsService = MockAnalyticsService();
    mockComposeRepository = MockComposeRepository();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();

    closeDispenserBloc = CloseDispenserBloc(
      signAndBroadcastTransactionUseCase:
          mockSignAndBroadcastTransactionUseCase,
      composeTransactionUseCase: mockComposeTransactionUseCase,
      fetchCloseDispenserFormDataUseCase:
          mockFetchCloseDispenserFormDataUseCase,
      analyticsService: mockAnalyticsService,
      composeRepository: mockComposeRepository,
      writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
    );

    mockDashboardActivityFeedBloc = MockDashboardActivityFeedBloc();
  });

  tearDown(() async {
    await closeDispenserBloc.close();
  });

  group('Close dispenser form', () {
    testWidgets('submits transaction', (WidgetTester tester) async {
      final composeDispenserResponse = ComposeDispenserResponseVerbose(
          rawtransaction: "test-raw-tx",
          name: "test-name",
          btcIn: 0,
          btcOut: 0,
          btcChange: 0,
          btcFee: 0,
          data: "test-data",
          params: const ComposeDispenserResponseVerboseParams(
            source: "test-address",
            asset: "test-asset",
            giveQuantity: 1,
            escrowQuantity: 1,
            mainchainrate: 10000,
            giveQuantityNormalized: "test-give-quantity-normalized",
            escrowQuantityNormalized: "test-escrow-quantity-normalized",
            status: 0,
            openAddress: "test-address",
          ),
          signedTxEstimatedSize: SignedTxEstimatedSize(
            virtualSize: 100,
            adjustedVirtualSize: 100,
            sigopsCount: 1,
          ));

      // Mock dependencies
      when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                [
                  FakeDispenser(
                    asset: 'ASSET1_DIVISIBLE',
                    source: 'test-address',
                    giveQuantity: 100000000,
                    giveQuantityNormalized: 'test-give-quantity-normalized',
                    escrowQuantity: 100000000,
                    status: 0,
                    satoshirate: 100000000,
                    satoshirateNormalized: "test-satoshi-rate-normalized",
                  ),
                  FakeDispenser(
                      asset: 'ASSET2_NOT_DIVISIBLE',
                      source: 'test-address',
                      giveQuantity: 10,
                      giveQuantityNormalized: 'test-give-quantity-normalized',
                      escrowQuantity: 10,
                      status: 0,
                      satoshirate: 100,
                      satoshirateNormalized: "test-satoshi-rate-normalized"),
                ]
              ));

      when(() => mockComposeTransactionUseCase
          .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
              feeRate: 5, // medium
              source: "test-address",
              composeFn: any(named: 'composeFn'),
              params: any(named: 'params'))).thenAnswer(
        (_) async => composeDispenserResponse,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<CloseDispenserBloc>.value(
                    value: closeDispenserBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                    value: mockDashboardActivityFeedBloc),
              ],
              child: CloseDispenserPage(
                address: FakeAddress().address,
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      closeDispenserBloc.add(AsyncFormDependenciesRequested(
          currentAddress: FakeAddress().address));
      await tester.pumpAndSettle();

      // Find and tap the asset dropdown
      final assetDropdown =
          find.byType(HorizonUI.HorizonDropdownMenu<Dispenser>);
      expect(assetDropdown, findsOneWidget);

      await tester.tap(assetDropdown);
      await tester.pumpAndSettle();

      // Select the first item in the dropdown
      final firstItemFinder = find
          .text(
            'ASSET1_DIVISIBLE - Quantity: test-give-quantity-normalized - Price: test-satoshi-rate-normalized',
          )
          .last;
      expect(firstItemFinder, findsOneWidget);

      await tester.tap(firstItemFinder);
      await tester.pumpAndSettle();

      // Tap the 'CONTINUE' button to compose the transaction
      final continueButton = find.widgetWithText(ElevatedButton, 'CONTINUE');
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      closeDispenserBloc.add(FormSubmitted(
        sourceAddress: "test-address",
        params: MockComposeDispenserEventParams(),
      ));

      // Assert that the confirmation page is displayed
      expect(
        find.textContaining('Please review your transaction details.'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();

      final confirmContinueButton =
          find.widgetWithText(ElevatedButton, 'CONTINUE');
      expect(confirmContinueButton, findsOneWidget);

      await tester.tap(confirmContinueButton);
      await tester.pumpAndSettle();

      closeDispenserBloc.add(ReviewSubmitted<ComposeDispenserResponseVerbose>(
        composeTransaction: composeDispenserResponse,
        fee: 5,
      ));

      await tester.pumpAndSettle();

      // Assert that the password page is displayed
      final passwordField = find.byType(HorizonUI.HorizonTextFormField);
      expect(passwordField, findsOneWidget);

      await tester.enterText(passwordField, 'test-password');
      await tester.pumpAndSettle();
    });
  });
}
