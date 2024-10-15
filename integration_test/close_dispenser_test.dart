import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/close_dispenser/view/close_dispenser_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:mocktail/mocktail.dart';

import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
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

class MockSignAndBroadcastTransactionUseCase extends Mock
    implements SignAndBroadcastTransactionUseCase {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class MockUtxoRepository extends Mock implements UtxoRepository {}

class MockDashboardActivityFeedBloc extends Mock
    implements DashboardActivityFeedBloc {}

class MockGetVirtualSizeUseCase extends Mock implements GetVirtualSizeUseCase {}

class MockShellStateCubit extends Mock implements ShellStateCubit {
  @override
  ShellState get state => const ShellState.success(ShellStateSuccess(
        accounts: [],
        redirect: false,
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
  late MockGetVirtualSizeUseCase mockGetVirtualSizeUseCase;
  late MockUtxoRepository mockUtxoRepository;

  setUpAll(() {
    registerFallbackValue(FakeAddress());
    registerFallbackValue(
        FakeComposeFunction<ComposeDispenserResponseVerbose>());
    registerFallbackValue(FakeComposeDispenserParams());
  });

  setUp(() {
    mockGetVirtualSizeUseCase = MockGetVirtualSizeUseCase();
    mockUtxoRepository = MockUtxoRepository();
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
    testWidgets('renders correct fields', (WidgetTester tester) async {
      // Mock dependencies
      when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                [
                  Dispenser(
                    assetName: 'ASSET1_DIVISIBLE',
                    openAddress: 'test-address',
                    giveQuantity: 100000000,
                    escrowQuantity: 100000000,
                    status: 0,
                    mainchainrate: 100000000,
                  ),
                  Dispenser(
                    assetName: 'ASSET2_NOT_DIVISIBLE',
                    openAddress: 'test-address',
                    giveQuantity: 10,
                    escrowQuantity: 10,
                    status: 0,
                    mainchainrate: 100,
                  ),
                ]
              ));

      when(() => mockWriteLocalTransactionUseCase.call(any(), any()))
          .thenAnswer((_) async {});

      when(() => mockAnalyticsService.trackEvent(any()))
          .thenAnswer((_) async {});

      // Build the widget tree
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
                address: FakeAddress(),
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      closeDispenserBloc.add(FetchFormData(currentAddress: FakeAddress()));

      await tester.pumpAndSettle();

      final assetDropdown =
          find.byType(HorizonUI.HorizonDropdownMenu<Dispenser>);
      expect(assetDropdown, findsOneWidget);

      await tester.tap(assetDropdown);
      await tester.pumpAndSettle();

      // Assert that the dropdown contains the desired items
      expect(
          find.widgetWithText(
              DropdownMenuItem<Dispenser>,
              'test-address - ASSET1_DIVISIBLE - '
              'Quantity: 100000000 - '
              'Price: 100000000'),
          findsOneWidget);
      expect(
          find.widgetWithText(
              DropdownMenuItem<Dispenser>,
              'test-address - ASSET2_NOT_DIVISIBLE - '
              'Quantity: 10 - '
              'Price: 100'),
          findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('submits transaction', (WidgetTester tester) async {
      const composeDispenserResponse = ComposeDispenserResponseVerbose(
          rawtransaction: "test-raw-tx",
          name: "test-name",
          btcIn: 0,
          btcOut: 0,
          btcChange: 0,
          btcFee: 0,
          data: "test-data",
          params: ComposeDispenserResponseVerboseParams(
            source: "test-address",
            asset: "test-asset",
            giveQuantity: 1,
            escrowQuantity: 1,
            mainchainrate: 10000,
            giveQuantityNormalized: "test-give-quantity-normalized",
            escrowQuantityNormalized: "test-escrow-quantity-normalized",
            status: 0,
          ));

      // Mock dependencies
      when(() => mockFetchCloseDispenserFormDataUseCase.call(any()))
          .thenAnswer((_) async => (
                const FeeEstimates(fast: 10, medium: 5, slow: 2),
                [
                  Dispenser(
                    assetName: 'ASSET1_DIVISIBLE',
                    openAddress: 'test-address',
                    giveQuantity: 100000000,
                    escrowQuantity: 100000000,
                    status: 0,
                    mainchainrate: 100000000,
                  ),
                  Dispenser(
                    assetName: 'ASSET2_NOT_DIVISIBLE',
                    openAddress: 'test-address',
                    giveQuantity: 10,
                    escrowQuantity: 10,
                    status: 0,
                    mainchainrate: 100,
                  ),
                ]
              ));

      when(() => mockComposeTransactionUseCase
              .call<ComposeDispenserParams, ComposeDispenserResponseVerbose>(
                  feeRate: 5, // medium
                  source: "test-address",
                  composeFn: any(named: 'composeFn'),
                  params: any(named: 'params')))
          .thenAnswer((_) async => composeDispenserResponse);

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
                address: FakeAddress(),
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
              ),
            ),
          ),
        ),
      );

      closeDispenserBloc.add(FetchFormData(currentAddress: FakeAddress()));
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
            'test-address - ASSET1_DIVISIBLE - Quantity: 100000000 - Price: 100000000',
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

      closeDispenserBloc.add(ComposeTransactionEvent(
        sourceAddress: "test-address",
        params: CloseDispenserParams(
          asset: "test-asset",
          giveQuantity: 1,
          escrowQuantity: 1,
          mainchainrate: 10000,
          status: 10,
        ),
      ));

      // Assert that the confirmation page is displayed
      expect(
        find.textContaining('Please review your transaction details.'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
      await tester.pumpAndSettle();

      closeDispenserBloc
          .add(FinalizeTransactionEvent<ComposeDispenserResponseVerbose>(
        composeTransaction: composeDispenserResponse,
        fee: 5,
      ));

      // Assert that the password page is displayed
      final passwordField = find.byType(HorizonUI.HorizonTextFormField);
      expect(passwordField, findsOneWidget);

      await tester.enterText(passwordField, 'test-password');
      await tester.pumpAndSettle();

      await tester
          .tap(find.widgetWithText(ElevatedButton, 'SIGN AND BROADCAST'));
      await tester.pumpAndSettle();

      closeDispenserBloc
          .add(SignAndBroadcastTransactionEvent(password: 'test-password'));
      await tester.pumpAndSettle();

      when(() => mockSignAndBroadcastTransactionUseCase.call(
              password: 'test-password',
              extractParams: any(named: 'extractParams'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError')))
          .thenAnswer((_) async => composeDispenserResponse);
    });
  });
}
