import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_event.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/bloc/account_form_state.dart';
import 'package:horizon/presentation/screens/dashboard/account_form/view/account_form.dart';
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
  final ShellState _state = ShellState.success(ShellStateSuccess(
      accounts: [
        Account(
          uuid: 'test-account-uuid',
          name: 'Test Account',
          walletUuid: 'test-wallet-uuid',
          purpose: "44'",
          coinType: "0'",
          accountIndex: "0'",
          importFormat: ImportFormat.counterwallet,
        )
      ],
      redirect: false,
      wallet: const Wallet(
          name: 'Test Wallet',
          uuid: 'test-wallet-uuid',
          publicKey: '',
          encryptedPrivKey: '',
          chainCodeHex: ''),
      currentAccountUuid: 'test-account-uuid',
      addresses: [],
      currentAddress: const Address(
        address: 'test-address',
        accountUuid: 'test-account-uuid',
        index: 1,
      )));

  @override
  ShellState get state => _state;

  @override
  Stream<ShellState> get stream => Stream.value(_state);
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
      mockShellCubit = MockShellStateCubit();
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
          find.byType(HorizonTextFormField).first, 'Test Account');
      await tester.pumpAndSettle();

      // Tap CONTINUE button
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();

      // Verify Finalize event is added
      verify(() => mockBloc.add(any(that: isA<Finalize>()))).called(1);

      // Enter password
      await tester.enterText(
          find.byType(HorizonTextFormField).last, 'password123');
      await tester.pumpAndSettle();

      // Tap SUBMIT button
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();

      // Wait for loading state to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Verify Submit event is added with correct parameters
      verify(() => mockBloc.add(any(that: isA<Submit>()))).called(1);
    });
  });
}
