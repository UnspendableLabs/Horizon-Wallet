import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_event.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_state.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/view/account_form.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountFormBloc extends Mock implements AccountFormBloc {
  final _stateController = StreamController<AccountFormState>.broadcast();
  AccountFormState _currentState = AccountFormStep1();

  MockAccountFormBloc() {
    when(() => stream).thenAnswer((_) => _stateController.stream);
    when(() => state).thenReturn(_currentState);
    when(() => add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments[0] as AccountFormEvent;
      if (event is Finalize) {
        _currentState = AccountFormStep2(state: Step2Initial());
        _stateController.add(_currentState);
      } else if (event is Submit) {
        _currentState = AccountFormStep2(state: Step2Loading());
        _stateController.add(_currentState);
        // Simulate async operation
        Future.delayed(const Duration(milliseconds: 500), () {
          _currentState = AccountFormStep2(
              state: Step2Success(Account(
            uuid: 'test-account-uuid',
            name: 'Test Account',
            walletUuid: 'test-wallet-uuid',
            purpose: "44'",
            coinType: "0'",
            accountIndex: "0'",
            importFormat: ImportFormat.counterwallet,
          )));
          _stateController.add(_currentState);
        });
      }
    });
  }

  @override
  Future<void> close() async {
    await _stateController.close();
    // return super.close();
  }
}

class MockShellStateCubit extends Mock implements ShellStateCubit {
  final ShellState _state;

  MockShellStateCubit(this._state);

  @override
  ShellState get state => _state;

  @override
  Stream<ShellState> get stream => Stream.value(_state);
}

ShellState createShellState({
  List<Account>? accounts,
  Wallet? wallet,
  String? currentAccountUuid,
  List<Address>? addresses,
  Address? currentAddress,
  bool redirect = false,
}) {
  // Define a default account
  final defaultAccount = Account(
    uuid: 'test-account-uuid',
    name: 'Test Account',
    walletUuid: 'test-wallet-uuid',
    purpose: "44'",
    coinType: "0'",
    accountIndex: "0'",
    importFormat: ImportFormat.counterwallet,
  );

  return ShellState.success(
    ShellStateSuccess(
      accounts: accounts ??
          [defaultAccount], // Include default account if none provided
      wallet: wallet ??
          const Wallet(
            name: 'Test Wallet',
            uuid: 'test-wallet-uuid',
            publicKey: '',
            encryptedPrivKey: '',
            chainCodeHex: '',
          ),
      currentAccountUuid: currentAccountUuid ?? defaultAccount.uuid,
      addresses: addresses ?? [],
      currentAddress: currentAddress ??
          Address(
            address: 'test-address',
            accountUuid: defaultAccount.uuid,
            index: 1,
          ),
      redirect: redirect,
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Finalize());
  });

  group('AddAccountForm Integration Test', () {
    late MockAccountFormBloc mockBloc;
    late MockShellStateCubit mockShellCubit;

    setUp(() {
      mockBloc = MockAccountFormBloc();
      mockShellCubit = MockShellStateCubit(createShellState());
    });

    tearDown(() async {
      await mockBloc.close();
    });

    testWidgets(
        'AddAccountForm - enter name, continue, enter password, and submit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<AccountFormBloc>.value(value: mockBloc),
                BlocProvider<ShellStateCubit>.value(value: mockShellCubit),
              ],
              child: const AddAccountForm(),
            ),
          ),
        ),
      );

      // Enter account name
      await tester.enterText(
          find.byType(HorizonUI.HorizonTextFormField).first, 'Test Account');
      await tester.pumpAndSettle();

      // Tap CONTINUE button
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Verify Finalize event is added
      verify(() => mockBloc.add(any(that: isA<Finalize>()))).called(1);

      // Enter password
      await tester.enterText(
          find.byType(HorizonUI.HorizonTextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap SUBMIT button
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();

      // Wait for loading state to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Capture the Submit event
      final verificationResult = verify(() => mockBloc.add(captureAny()));

      // Assert that the 2 events were added to the bloc
      verificationResult.called(2);

      // Retrieve the captured submit event
      final capturedEvents = verificationResult.captured;
      final submitEvent =
          capturedEvents.firstWhere((event) => event is Submit) as Submit;

      // Assert the properties of the Submit event
      expect(submitEvent.name, 'Test Account');
      expect(submitEvent.password, 'password123');
      expect(submitEvent.accountIndex, "1'");
      expect(submitEvent.walletUuid, 'test-wallet-uuid');
      expect(submitEvent.purpose, "44'");
      expect(submitEvent.coinType, "0'");
      expect(submitEvent.importFormat, ImportFormat.counterwallet);
    });

    testWidgets('Test with custom accounts', (WidgetTester tester) async {
      // Define custom accounts
      final accounts = [
        Account(
          uuid: 'account-uuid-1',
          name: 'Account 1',
          walletUuid: 'wallet-uuid-1',
          purpose: "44'",
          coinType: "0'",
          accountIndex: "0'",
          importFormat: ImportFormat.counterwallet,
        ),
        Account(
          uuid: 'account-uuid-2',
          name: 'Account 2',
          walletUuid: 'wallet-uuid-1',
          purpose: "44'",
          coinType: "0'",
          accountIndex: "1'",
          importFormat: ImportFormat.counterwallet,
        ),
        Account(
          uuid: 'account-uuid-3',
          name: 'Account 3',
          walletUuid: 'wallet-uuid-1',
          purpose: "44'",
          coinType: "0'",
          accountIndex: "2'",
          importFormat: ImportFormat.counterwallet,
        ),
      ];

      // Create a ShellState with these accounts
      final shellState = createShellState(
        accounts: accounts,
        currentAccountUuid: 'account-uuid-2',
      );

      // Initialize MockShellStateCubit with the custom ShellState
      final mockShellCubit = MockShellStateCubit(shellState);

      // Initialize MockAccountFormBloc
      final mockBloc = MockAccountFormBloc();

      // Build your widget under test
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<AccountFormBloc>.value(value: mockBloc),
                BlocProvider<ShellStateCubit>.value(value: mockShellCubit),
              ],
              child: const AddAccountForm(),
            ),
          ),
        ),
      );

      // Enter account name
      await tester.enterText(
          find.byType(HorizonUI.HorizonTextFormField).first, 'Test Account');
      await tester.pumpAndSettle();

      // Tap CONTINUE button
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Verify Finalize event is added
      verify(() => mockBloc.add(any(that: isA<Finalize>()))).called(1);

      // Enter password
      await tester.enterText(
          find.byType(HorizonUI.HorizonTextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap SUBMIT button
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();

      // Wait for loading state to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Capture the Submit event
      final verificationResult = verify(() => mockBloc.add(captureAny()));

      // Assert that the 2 events were added to the bloc
      verificationResult.called(2);

      // Retrieve the captured submit event
      final capturedEvents = verificationResult.captured;
      final submitEvent =
          capturedEvents.firstWhere((event) => event is Submit) as Submit;

      // Assert the properties of the Submit event
      expect(submitEvent.name, 'Test Account');
      expect(submitEvent.password, 'password123');
      expect(submitEvent.accountIndex, "3'");
      expect(submitEvent.walletUuid, 'wallet-uuid-1');
      expect(submitEvent.purpose, "44'");
      expect(submitEvent.coinType, "0'");
      expect(submitEvent.importFormat, ImportFormat.counterwallet);
    });
  });
}
