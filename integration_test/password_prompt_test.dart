import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingState extends Mock {
  String? passwordError;
}

void main() {
  group('PasswordPrompt Widget Tests', () {
    late TextEditingController passwordController;
    late TextEditingController passwordConfirmationController;
    late MockOnboardingState mockState;

    setUp(() {
      passwordController = TextEditingController();
      passwordConfirmationController = TextEditingController();
      mockState = MockOnboardingState();
    });

    tearDown(() {
      passwordController.dispose();
      passwordConfirmationController.dispose();
    });

    testWidgets('PasswordPrompt renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PasswordPrompt(
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

      expect(find.text('Please create a password'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('PasswordPrompt shows error message',
        (WidgetTester tester) async {
      mockState.passwordError = 'Password error';

      await tester.pumpWidget(
        MaterialApp(
          home: PasswordPrompt(
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

      expect(find.text('Password error'), findsOneWidget);
    });

    testWidgets('PasswordPrompt calls onPasswordChanged',
        (WidgetTester tester) async {
      bool onPasswordChangedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PasswordPrompt(
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
      expect(onPasswordChangedCalled, isTrue);
    });

    testWidgets('PasswordPrompt calls onPasswordConfirmationChanged',
        (WidgetTester tester) async {
      bool onPasswordConfirmationChangedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PasswordPrompt(
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
      expect(onPasswordConfirmationChangedCalled, isTrue);
    });
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
