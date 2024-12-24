import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/view/compose_attach_utxo_page.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

/// --------------------------------------------------------------------------
/// Mocks & Fakes
/// --------------------------------------------------------------------------
class MockShellStateCubit extends Mock implements ShellStateCubit {
  @override
  ShellState get state => ShellState.success(
        ShellStateSuccess.withAccount(
          accounts: [],
          redirect: false,
          wallet: const Wallet(
            name: 'Test Wallet',
            uuid: 'test-wallet-uuid',
            publicKey: '',
            encryptedPrivKey: '',
            chainCodeHex: '',
          ),
          currentAccountUuid: 'test-account-uuid',
          addresses: [],
          currentAddress: const Address(
            address: 'test-address',
            accountUuid: 'test-account-uuid',
            index: 0,
          ),
        ),
      );
}

class MockDashboardActivityFeedBloc extends Mock implements DashboardActivityFeedBloc {}

class MockBlockRepository extends Mock implements BlockRepository {}

class MockLogger extends Mock implements Logger {}

class MockFetchComposeAttachUtxoFormDataUseCase extends Mock implements FetchComposeAttachUtxoFormDataUseCase {}

class MockComposeTransactionUseCase extends Mock implements ComposeTransactionUseCase {}

class MockSignAndBroadcastTransactionUseCase extends Mock implements SignAndBroadcastTransactionUseCase {}

class MockWriteLocalTransactionUseCase extends Mock implements WriteLocalTransactionUseCase {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockComposeRepository extends Mock implements ComposeRepository {}

class FakeAddress extends Fake implements Address {}

class FakeComposeAttachUtxoParams extends Fake implements ComposeAttachUtxoEventParams {}

// This is a minimal “dummy” ComposeAttachUtxoResponse to help test
class FakeComposeAttachUtxoResponse extends Fake implements ComposeAttachUtxoResponse {
  @override
  final ComposeAttachUtxoResponseParams params;

  FakeComposeAttachUtxoResponse({
    required this.params,
  });
}

class FakeComposeAttachUtxoResponseParams extends Fake implements ComposeAttachUtxoResponseParams {
  @override
  final String asset;

  @override
  final int quantity;

  @override
  final String quantityNormalized;

  FakeComposeAttachUtxoResponseParams({
    required this.asset,
    required this.quantity,
    required this.quantityNormalized,
  });
}

/// If your composeTransactionUseCase expects a 2-tuple with a VirtualSize,
/// you must provide a class implementing it. Example below.
/// If your code doesn't require VirtualSize, you can omit this.
///
/// For demonstration, we define a trivial FakeVirtualSize that we can return
/// to match the signature (ComposeAttachUtxoResponse, VirtualSize).
class VirtualSize {
  final int virtualSize;
  final int adjustedVirtualSize;

  VirtualSize({
    required this.virtualSize,
    required this.adjustedVirtualSize,
  });
}

class FakeVirtualSize extends Fake implements VirtualSize {
  @override
  final int virtualSize;
  @override
  final int adjustedVirtualSize;

  FakeVirtualSize({
    required this.virtualSize,
    required this.adjustedVirtualSize,
  });
}

class MockComposeAttachUtxoResponseParams extends Mock implements ComposeAttachUtxoResponseParams {
  @override
  String get source => "source";
}

class MockComposeAttachUtxoResponse extends Mock implements ComposeAttachUtxoResponse {
  @override
  final MockComposeAttachUtxoResponseParams params = MockComposeAttachUtxoResponseParams();

  @override
  String get rawtransaction => "rawtransaction";
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockShellStateCubit mockShellStateCubit;
  late MockDashboardActivityFeedBloc mockDashboardActivityFeedBloc;
  late MockFetchComposeAttachUtxoFormDataUseCase mockFetchFormDataUseCase;
  late MockComposeTransactionUseCase mockComposeTransactionUseCase;
  late MockSignAndBroadcastTransactionUseCase mockSignAndBroadcastTransactionUseCase;
  late MockWriteLocalTransactionUseCase mockWriteLocalTransactionUseCase;
  late MockAnalyticsService mockAnalyticsService;
  late MockComposeRepository mockComposeRepository;
  late MockBlockRepository mockBlockRepository;
  late MockLogger mockLogger;

  setUpAll(() {
    registerFallbackValue(FakeAddress());
    registerFallbackValue(FakeComposeAttachUtxoParams());
  });

  setUp(() {
    mockShellStateCubit = MockShellStateCubit();
    mockDashboardActivityFeedBloc = MockDashboardActivityFeedBloc();
    mockFetchFormDataUseCase = MockFetchComposeAttachUtxoFormDataUseCase();
    mockComposeTransactionUseCase = MockComposeTransactionUseCase();
    mockSignAndBroadcastTransactionUseCase = MockSignAndBroadcastTransactionUseCase();
    mockWriteLocalTransactionUseCase = MockWriteLocalTransactionUseCase();
    mockAnalyticsService = MockAnalyticsService();
    mockComposeRepository = MockComposeRepository();
    mockBlockRepository = MockBlockRepository();
    mockLogger = MockLogger();
  });

  group('ComposeAttachUtxo Integration Test', () {
    testWidgets(
        'Submits correct params (divisible vs non-divisible) with no "argThat" usage, returning (ComposeAttachUtxoResponse, VirtualSize)',
        (tester) async {
      // 1) Mock: fetchFormData -> returns a FeeEstimates, a list of balances, and an int xcp fee
      when(() => mockFetchFormDataUseCase.call(any())).thenAnswer((_) async {
        return (
          const FeeEstimates(fast: 10, medium: 5, slow: 2),
          [
            // Divisible asset
            Balance(
              address: "test-address",
              asset: "ASSET1_DIVISIBLE",
              quantity: 250000000, // 2.5
              quantityNormalized: "2.5",
              assetInfo: const AssetInfo(
                assetLongname: null,
                description: "A divisible asset",
                issuer: "test-address",
                divisible: true,
              ),
            ),
            // Non-divisible
            Balance(
              address: "test-address",
              asset: "ASSET2_NOT_DIVISIBLE",
              quantity: 10, // means 10
              quantityNormalized: "10",
              assetInfo: const AssetInfo(
                assetLongname: null,
                description: "A non-divisible asset",
                issuer: "test-address",
                divisible: false,
              ),
            ),
          ],
          100 // xcp fee
        );
      });

      // 2) Mock: composeTransaction -> return a dummy (ComposeAttachUtxoResponse, VirtualSize)
      final mockComposeAttachUtxoResponse = MockComposeAttachUtxoResponse();

      final response = (
        mockComposeAttachUtxoResponse,
        FakeVirtualSize(
          virtualSize: 100,
          adjustedVirtualSize: 100,
        )
      );

      when(
        () => mockComposeTransactionUseCase.call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
          feeRate: any(named: 'feeRate'),
          source: any(named: 'source'),
          params: any(named: 'params'),
          composeFn: any(named: 'composeFn'),
        ),
      ).thenAnswer((_) async => Future<(ComposeAttachUtxoResponse, VirtualSize)>.value((
            mockComposeAttachUtxoResponse,
            FakeVirtualSize(
              virtualSize: 100,
              adjustedVirtualSize: 100,
            )
          )));

      // 3) Build the actual widget under test
      final attachBloc = ComposeAttachUtxoBloc(
        logger: mockLogger,
        fetchComposeAttachUtxoFormDataUseCase: mockFetchFormDataUseCase,
        analyticsService: mockAnalyticsService,
        composeTransactionUseCase: mockComposeTransactionUseCase,
        composeRepository: mockComposeRepository,
        signAndBroadcastTransactionUseCase: mockSignAndBroadcastTransactionUseCase,
        writelocalTransactionUseCase: mockWriteLocalTransactionUseCase,
        blockRepository: mockBlockRepository,
      )..add(FetchFormData(currentAddress: "test-address"));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeAttachUtxoBloc>.value(value: attachBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                  value: mockDashboardActivityFeedBloc,
                ),
              ],
              child: ComposeAttachUtxoPage(
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
                address: "test-address",
                assetName: "ASSET1_DIVISIBLE", // start with divisible
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter "1.5" for the divisible asset -> expect quantity = 1.5 * 100000000
      final quantityInputFinder = find.byKey(const Key('quantity_input'));
      expect(quantityInputFinder, findsOneWidget);

      await tester.enterText(quantityInputFinder, '1.5');
      await tester.pumpAndSettle();

      // Tap the "CONTINUE" button
      final continueButtonFinder = find.widgetWithText(ElevatedButton, 'CONTINUE');
      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();

      // Capture the call for the divisible asset
      final divisibleVerifyCall = verify(
        () => mockComposeTransactionUseCase.call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
          feeRate: captureAny(named: 'feeRate'),
          source: captureAny(named: 'source'),
          params: captureAny(named: 'params'),
          composeFn: captureAny(named: 'composeFn'),
        ),
      );
      divisibleVerifyCall.called(1);

      // Evaluate the captured arguments
      final capturedDivisible = divisibleVerifyCall.captured[2] as ComposeAttachUtxoParams;
      expect(capturedDivisible.asset, 'ASSET1_DIVISIBLE');
      expect(capturedDivisible.quantity, 150000000); // 1.5 * 100000000
      expect(divisibleVerifyCall.captured[0], 5); // medium feeRate
      expect(divisibleVerifyCall.captured[1], 'test-address');

      // Now let's test the non-divisible asset path
      // Switch the asset to the other one
      attachBloc.add(FetchFormData(currentAddress: "test-address"));
      await tester.pumpAndSettle();

      // Rebuild the ComposeAttachUtxoPage but with the new asset
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ComposeAttachUtxoBloc>.value(value: attachBloc),
                BlocProvider<DashboardActivityFeedBloc>.value(
                  value: mockDashboardActivityFeedBloc,
                ),
              ],
              child: ComposeAttachUtxoPage(
                dashboardActivityFeedBloc: mockDashboardActivityFeedBloc,
                address: "test-address",
                assetName: "ASSET2_NOT_DIVISIBLE",
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter "3" (non-divisible asset => exactly 3)
      await tester.enterText(quantityInputFinder, '3');
      await tester.pumpAndSettle();

      // Tap CONTINUE
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();

      final nonDivisibleVerifyCall = verify(
        () => mockComposeTransactionUseCase.call<ComposeAttachUtxoParams, ComposeAttachUtxoResponse>(
          feeRate: captureAny(named: 'feeRate'),
          source: captureAny(named: 'source'),
          params: captureAny(named: 'params'),
          composeFn: captureAny(named: 'composeFn'),
        ),
      );
      nonDivisibleVerifyCall.called(1);

      // Evaluate captured arguments
      final capturedNonDivisible = nonDivisibleVerifyCall.captured[2] as ComposeAttachUtxoParams;
      expect(capturedNonDivisible.asset, 'ASSET2_NOT_DIVISIBLE');
      expect(capturedNonDivisible.quantity, 3); // no scaling for non-divisible

      expect(nonDivisibleVerifyCall.captured[0], 5); // medium feeRate
      expect(nonDivisibleVerifyCall.captured[1], 'test-address');
    });
  });
}
