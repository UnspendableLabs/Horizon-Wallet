import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/presentation/common/theme_extension.dart';

class MockOnboardingState extends Mock {}

class MockOnboardingCreateBloc extends Mock implements OnboardingCreateBloc {}

class FakeOnboardingCreateEvent extends Fake implements OnboardingCreateEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOnboardingCreateEvent());
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
      theme: ThemeData(
        extensions: [
          CustomThemeExtension(
            inputBackground: Colors.white,
            inputBackgroundEmpty: Colors.grey[100]!,
            inputBorderColor: Colors.grey[300]!,
            inputTextColor: Colors.black,
            errorColor: Colors.red,
            errorBackgroundColor: Colors.red[50]!,
            settingsItemBackground: transparentBlack66,
            bgBlackOrWhite: Colors.white,
            mutedDescriptionTextColor: Colors.grey[600]!,
            number50Regular: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[50]!,
            ),
          ),
        ],
      ),
      home: BlocProvider<OnboardingCreateBloc>.value(
        value: mockBloc,
        child: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('PasswordPrompt Widget Tests', () {
    testWidgets(
      'PasswordPrompt renders correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            PasswordPrompt(
              key: GlobalKey<PasswordPromptState>(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Please create a password'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
      },
    );
  });

  testWidgets('PasswordPrompt enforces confirmation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return PasswordPrompt(
              key: GlobalKey<PasswordPromptState>(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter a valid password without confirmation
    await tester.enterText(find.byType(TextField).first, 'validpassword123');
    await tester.pumpAndSettle();

    // Focus the confirmation field
    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();

    // Enter some text
    await tester.enterText(find.byType(TextField).last, 'test');
    await tester.pumpAndSettle();

    // Simulate backspacing each character
    for (int i = 4; i > 0; i--) {
      tester.testTextInput.updateEditingValue(TextEditingValue(
        text: 'test'.substring(0, i - 1),
        selection: TextSelection.collapsed(offset: i - 1),
      ));
      await tester.pumpAndSettle();
    }

    expect(find.text('Please confirm your password'), findsNWidgets(1));
  });

  testWidgets(
    'PasswordPrompt shows error when passwords do not match',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            key: GlobalKey<PasswordPromptState>(),
          ),
        ),
      );

      // Enter a short password
      await tester.enterText(find.byType(TextField).first, 'password123');
      await tester.pumpAndSettle();

      // Enter a valid password
      await tester.enterText(find.byType(TextField).last, 'validpassword123');
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    },
  );

  testWidgets(
    'PasswordPrompt shows error when password is too short',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            key: GlobalKey<PasswordPromptState>(),
          ),
        ),
      );

      // Enter a short password
      await tester.enterText(find.byType(TextField).first, 'short');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'short');
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters'),
          findsNWidgets(2));
    },
  );

  testWidgets(
    'PasswordPrompt allows password when confirmation is valid',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          PasswordPrompt(
            key: GlobalKey<PasswordPromptState>(),
          ),
        ),
      );

      // Enter a valid password
      await tester.enterText(find.byType(TextField).first, 'password123');
      await tester.pumpAndSettle();

      // Enter valid confirmation
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pumpAndSettle();
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
