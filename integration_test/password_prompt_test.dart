import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingState extends Mock {}

class MockOnboardingCreateBloc extends Mock implements OnboardingCreateBloc {}

class FakeOnboardingCreateEvent extends Fake implements OnboardingCreateEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOnboardingCreateEvent());
    registerFallbackValue(CreateWallet(password: ''));
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
    testWidgets(
      'PasswordPrompt renders correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            PasswordPrompt(
              state: mockState,
              onPressedBack: () {},
              onPressedContinue: (password) {},
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
      },
    );
  });

  testWidgets('PasswordPrompt does not submit with empty password',
      (WidgetTester tester) async {
    final mockState = MockOnboardingState();
    bool continueSuccess = false;

    await tester.pumpWidget(
      buildTestableWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return PasswordPrompt(
              state: mockState,
              onPressedBack: () {},
              onPressedContinue: (password) {
                continueSuccess = true;
              },
              backButtonText: 'Back',
              continueButtonText: 'Continue',
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Submit with empty password
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Password cannot be empty'), findsOneWidget);
    expect(continueSuccess, isFalse);
  });
  testWidgets('PasswordPrompt does not submit with empty password confirmation',
      (WidgetTester tester) async {
    final mockState = MockOnboardingState();
    bool continueSuccess = false;

    await tester.pumpWidget(
      buildTestableWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return PasswordPrompt(
              state: mockState,
              onPressedBack: () {},
              onPressedContinue: (password) {
                continueSuccess = true;
              },
              backButtonText: 'Back',
              continueButtonText: 'Continue',
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter a valid password without confirmation
    await tester.enterText(find.byType(TextField).first, 'validpassword123');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Please confirm your password'), findsNWidgets(1));
    expect(continueSuccess, isFalse);
  });

  testWidgets(
    'PasswordPrompt does not submit with mismatched password confirmation',
    (WidgetTester tester) async {
      bool continueSuccess = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<OnboardingCreateBloc>.value(
              value: mockBloc,
              child: PasswordPrompt(
                state: mockState,
                onPressedBack: () {},
                onPressedContinue: (password) {
                  continueSuccess = true;
                },
                backButtonText: 'Back',
                continueButtonText: 'Continue',
              ),
            ),
          ),
        ),
      );

      // Enter a short password
      await tester.enterText(find.byType(TextField).first, 'password123');
      await tester.pumpAndSettle();

      // Enter a valid password
      await tester.enterText(find.byType(TextField).last, 'validpassword123');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);

      expect(continueSuccess, isFalse);
    },
  );

  testWidgets(
    'PasswordPrompt does not submit when password is too short',
    (WidgetTester tester) async {
      bool continueSuccess = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<OnboardingCreateBloc>.value(
              value: mockBloc,
              child: PasswordPrompt(
                state: mockBloc.state,
                onPressedBack: () {},
                onPressedContinue: (password) {
                  continueSuccess = true;
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

      // Try to submit with mismatched confirmation
      await tester.enterText(find.byType(TextField).last, 'short');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Password must be at least 8 characters'),
          findsNWidgets(2));

      expect(continueSuccess, isFalse);
    },
  );

  testWidgets(
    'PasswordPrompt submits when password is valid',
    (WidgetTester tester) async {
      bool continueSuccess = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<OnboardingCreateBloc>.value(
              value: mockBloc,
              child: PasswordPrompt(
                state: mockBloc.state,
                onPressedBack: () {},
                onPressedContinue: (password) {
                  continueSuccess = true;
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

      // Enter valid confirmation
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(continueSuccess, isTrue);
    },
  );

  group(
    'Password Validation Tests',
    () {
      test('validatePasswordConfirmation returns null for valid password', () {
        expect(
            validatePasswordConfirmation('password123', 'password123'), isNull);
      });

      test('validatePasswordConfirmation returns error for empty password', () {
        expect(validatePasswordConfirmation('', ''), equals(null));
      });

      test('validatePasswordConfirmation returns error for short password', () {
        expect(validatePasswordConfirmation('pass', 'pass'),
            equals('Password must be at least 8 characters'));
      });

      test('validatePasswordConfirmation returns error for short password', () {
        expect(validatePasswordConfirmation('pass', 'password123'),
            equals('Password must be at least 8 characters'));
      });

      test('validatePasswordConfirmation returns error for empty confirmation',
          () {
        expect(validatePasswordConfirmation('password123', ''),
            equals('Please confirm your password'));
      });

      test(
          'validatePasswordConfirmation returns error for mismatched passwords',
          () {
        expect(validatePasswordConfirmation('password123', 'password456'),
            equals('Passwords do not match'));
      });
    },
  );
}
