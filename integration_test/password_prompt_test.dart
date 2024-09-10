import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingState extends Mock {
  String? _passwordError;

  String? get passwordError => _passwordError;

  set passwordError(String? value) {
    _passwordError = value;
  }
}

class MockOnboardingCreateBloc extends Mock implements OnboardingCreateBloc {}

class FakeOnboardingCreateEvent extends Fake implements OnboardingCreateEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOnboardingCreateEvent());
    registerFallbackValue(PasswordChanged(password: ''));
    registerFallbackValue(PasswordError(error: ''));
    registerFallbackValue(CreateWallet());
  });

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TextEditingController passwordController;
  late TextEditingController passwordConfirmationController;
  late MockOnboardingState mockState;
  late MockOnboardingCreateBloc mockBloc;

  setUp(() {
    passwordController = TextEditingController();
    passwordConfirmationController = TextEditingController();
    mockState = MockOnboardingState();
    mockBloc = MockOnboardingCreateBloc();

    when(() => mockBloc.state).thenReturn(const OnboardingCreateState());
    when(() => mockBloc.stream)
        .thenAnswer((_) => Stream.value(const OnboardingCreateState()));
  });

  tearDown(() {
    passwordController.dispose();
    passwordConfirmationController.dispose();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
        home: Scaffold(
      body: child,
    ));
  }

  group('PasswordPrompt Widget Tests', () {
    testWidgets('PasswordPrompt renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            passwordController: passwordController,
            passwordConfirmationController: passwordConfirmationController,
            state: mockState,
            onPasswordChanged: (_) {},
            onPasswordConfirmationChanged: (_) {},
            onPressedBack: () {},
            onPressedContinue: () {},
            backButtonText: 'Back',
            continueButtonText: 'Continue',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Please create a password'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('PasswordPrompt shows error message',
        (WidgetTester tester) async {
      mockState.passwordError = 'Password error';

      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            passwordController: passwordController,
            passwordConfirmationController: passwordConfirmationController,
            state: mockState,
            onPasswordChanged: (_) {},
            onPasswordConfirmationChanged: (_) {},
            onPressedBack: () {},
            onPressedContinue: () {},
            backButtonText: 'Back',
            continueButtonText: 'Continue',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Password error'), findsOneWidget);
    });

    testWidgets('PasswordPrompt calls onPasswordChanged',
        (WidgetTester tester) async {
      bool onPasswordChangedCalled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            passwordController: passwordController,
            passwordConfirmationController: passwordConfirmationController,
            state: mockState,
            onPasswordChanged: (_) => onPasswordChangedCalled = true,
            onPasswordConfirmationChanged: (_) {},
            onPressedBack: () {},
            onPressedContinue: () {},
            backButtonText: 'Back',
            continueButtonText: 'Continue',
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'password');
      await tester.pumpAndSettle();

      expect(onPasswordChangedCalled, isTrue);
    });

    testWidgets('PasswordPrompt calls onPasswordConfirmationChanged',
        (WidgetTester tester) async {
      bool onPasswordConfirmationChangedCalled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            passwordController: passwordController,
            passwordConfirmationController: passwordConfirmationController,
            state: mockState,
            onPasswordChanged: (_) {},
            onPasswordConfirmationChanged: (_) =>
                onPasswordConfirmationChangedCalled = true,
            onPressedBack: () {},
            onPressedContinue: () {},
            backButtonText: 'Back',
            continueButtonText: 'Continue',
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.pumpAndSettle();

      expect(onPasswordConfirmationChangedCalled, isTrue);
    });

    testWidgets('PasswordPrompt handles password validation',
        (WidgetTester tester) async {
      final mockState = MockOnboardingState();

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return PasswordPrompt(
                passwordController: passwordController,
                passwordConfirmationController: passwordConfirmationController,
                state: mockState,
                onPasswordChanged: (_) {
                  setState(() {
                    final error = validatePassword(passwordController.text,
                        passwordConfirmationController.text);
                    mockState.passwordError = error;
                  });
                },
                onPasswordConfirmationChanged: (_) {},
                onPressedBack: () {},
                onPressedContinue: () {},
                backButtonText: 'Back',
                continueButtonText: 'Continue',
              );
            },
          ),
        ),
      );

      // Initially, there should be no error message
      expect(find.text('Password must be at least 8 characters'), findsNothing);

      // Enter a short password
      await tester.enterText(find.byType(TextField).first, 'foobar');
      await tester.pumpAndSettle();

      // Now the error message should appear
      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);

      // Enter a valid password
      await tester.enterText(find.byType(TextField).first, 'validpassword123');
      await tester.pumpAndSettle();

      // The error message should disappear
      expect(find.text('Password must be at least 8 characters'), findsNothing);
    });
  });

  testWidgets(
      'PasswordPrompt does not submit with mismatched password confirmation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<OnboardingCreateBloc>.value(
            value: mockBloc,
            child: PasswordPrompt(
              passwordController: passwordController,
              passwordConfirmationController: passwordConfirmationController,
              state: mockBloc.state,
              onPasswordChanged: (value) {
                final error =
                    validatePassword(value, passwordConfirmationController.text);
                if (error == null) {
                  mockBloc.add(PasswordChanged(password: value));
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              onPasswordConfirmationChanged: (value) {
                final error = validatePassword(passwordController.text, value);
                if (error == null) {
                  mockBloc.add(
                      PasswordConfirmationChanged(passwordConfirmation: value));
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              onPressedBack: () {},
              onPressedContinue: () {
                String? error = validatePasswordOnSubmit(
                    passwordController.text, passwordConfirmationController.text);
                if (error == null) {
                  mockBloc.add(CreateWallet());
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              backButtonText: 'Back',
              continueButtonText: 'Continue',
            ),
          ),
        ),
      ),
    );

    // Enter a short password
    await tester.enterText(find.byType(TextField).first, 'short');
    await tester.pumpAndSettle();

    // Verify that PasswordError event is added at least once
    verify(() => mockBloc.add(any(that: isA<PasswordError>()))).called(1);

    // Enter a valid password
    await tester.enterText(find.byType(TextField).first, 'validpassword123');
    await tester.pumpAndSettle();

    // Verify that PasswordChanged event is added
    verify(() => mockBloc.add(any(that: isA<PasswordChanged>()))).called(1);

    // Try to submit with mismatched confirmation
    await tester.enterText(find.byType(TextField).last, 'differentpassword');
    await tester.pumpAndSettle();

    // Verify that PasswordError event is added at least once for the confirmation field
    verify(() => mockBloc.add(any(that: isA<PasswordError>()))).called(1);

    // Submit the form
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify that CreateWallet event is not added and PasswordError is added
    verifyNever(() => mockBloc.add(any(that: isA<CreateWallet>())));
    verify(() => mockBloc.add(any(that: isA<PasswordError>()))).called(1);
  });

  testWidgets('PasswordPrompt does not submit when password is too short',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<OnboardingCreateBloc>.value(
            value: mockBloc,
            child: PasswordPrompt(
              passwordController: passwordController,
              passwordConfirmationController: passwordConfirmationController,
              state: mockBloc.state,
              onPasswordChanged: (value) {
                final error =
                    validatePassword(value, passwordConfirmationController.text);
                if (error == null) {
                  mockBloc.add(PasswordChanged(password: value));
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              onPasswordConfirmationChanged: (value) {
                final error = validatePassword(passwordController.text, value);
                if (error == null) {
                  mockBloc.add(
                      PasswordConfirmationChanged(passwordConfirmation: value));
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              onPressedBack: () {},
              onPressedContinue: () {
                String? error = validatePasswordOnSubmit(
                    passwordController.text, passwordConfirmationController.text);
                if (error == null) {
                  mockBloc.add(CreateWallet());
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              backButtonText: 'Back',
              continueButtonText: 'Continue',
            ),
          ),
        ),
      ),
    );

    // Enter a short password
    await tester.enterText(find.byType(TextField).first, 'short');
    await tester.pumpAndSettle();

    // Verify that PasswordError event is added at least once
    verify(() => mockBloc.add(any(that: isA<PasswordError>()))).called(1);

    // Try to submit with mismatched confirmation
    await tester.enterText(find.byType(TextField).last, 'short');
    await tester.pumpAndSettle();

    // Verify that PasswordError event is added at least once for the confirmation field
    verify(() => mockBloc.add(any(that: isA<PasswordError>()))).called(1);

    // Submit the form
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify that CreateWallet event is not added and PasswordError is added
    verifyNever(() => mockBloc.add(any(that: isA<CreateWallet>())));
    verify(() => mockBloc.add(any(that: isA<PasswordError>()))).called(1);
  });

  testWidgets('PasswordPrompt submits when password is valid',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<OnboardingCreateBloc>.value(
            value: mockBloc,
            child: PasswordPrompt(
              passwordController: passwordController,
              passwordConfirmationController: passwordConfirmationController,
              state: mockBloc.state,
              onPasswordChanged: (value) {
                final error =
                    validatePassword(value, passwordConfirmationController.text);
                if (error == null) {
                  mockBloc.add(PasswordChanged(password: value));
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              onPasswordConfirmationChanged: (value) {
                final error = validatePassword(passwordController.text, value);
                if (error == null) {
                  mockBloc.add(
                      PasswordConfirmationChanged(passwordConfirmation: value));
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              onPressedBack: () {},
              onPressedContinue: () {
                String? error = validatePasswordOnSubmit(
                    passwordController.text, passwordConfirmationController.text);
                if (error == null) {
                  mockBloc.add(CreateWallet());
                } else {
                  mockBloc.add(PasswordError(error: error));
                }
              },
              backButtonText: 'Back',
              continueButtonText: 'Continue',
            ),
          ),
        ),
      ),
    );

    // Enter a valid password
    await tester.enterText(find.byType(TextField).first, 'password123');
    await tester.pumpAndSettle();

    // Verify that PasswordChanged event is added at least once
    verifyNever(() => mockBloc.add(any(that: isA<PasswordError>())));
    verify(() => mockBloc.add(any(that: isA<PasswordChanged>()))).called(1);

    // Enter valid confirmation
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.pumpAndSettle();

    // Verify that PasswordConfirmationChanged event is added at least once
    verifyNever(() => mockBloc.add(any(that: isA<PasswordError>())));
    verify(() => mockBloc.add(any(that: isA<PasswordConfirmationChanged>())))
        .called(1);

    // Submit the form
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify that CreateWallet event is added and PasswordError is not added
    verifyNever(() => mockBloc.add(any(that: isA<PasswordError>())));
    verify(() => mockBloc.add(any(that: isA<CreateWallet>()))).called(1);
  });

  group('Password Validation Tests', () {
    test('validatePassword returns null for valid password', () {
      expect(validatePassword('password123', 'password123'), isNull);
    });

    test('validatePassword returns error for empty password', () {
      expect(validatePassword('', ''), equals('Password cannot be empty'));
    });

    test('validatePassword returns error for short password', () {
      expect(validatePassword('pass', 'pass'),
          equals('Password must be at least 8 characters'));
    });

    test('validatePassword returns error for mismatched passwords', () {
      expect(validatePassword('password123', 'password456'),
          equals('Passwords do not match'));
    });

    test('validatePasswordOnSubmit returns null for valid password', () {
      expect(validatePasswordOnSubmit('password123', 'password123'), isNull);
    });

    test('validatePasswordOnSubmit returns error for empty password', () {
      expect(
          validatePasswordOnSubmit('', ''), equals('Password cannot be empty'));
    });

    test('validatePasswordOnSubmit returns error for short password', () {
      expect(validatePasswordOnSubmit('pass', 'pass'),
          equals('Password must be at least 8 characters'));
    });

    test('validatePasswordOnSubmit returns error for short password', () {
      expect(validatePasswordOnSubmit('pass', 'password123'),
          equals('Password must be at least 8 characters'));
    });

    test('validatePasswordOnSubmit returns error for empty confirmation', () {
      expect(validatePasswordOnSubmit('password123', ''),
          equals('Please confirm your password'));
    });

    test('validatePasswordOnSubmit returns error for mismatched passwords', () {
      expect(validatePasswordOnSubmit('password123', 'password456'),
          equals('Passwords do not match'));
    });
  });
}
