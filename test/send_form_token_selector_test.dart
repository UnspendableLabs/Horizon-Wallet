import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/presentation/screens/send/forms/send_form_token_selector.dart';
import 'package:horizon/presentation/screens/send/bloc/token_selector_form_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client_factory.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

class MockTokenSelectorFormBloc
    extends MockBloc<TokenSelectorFormEvent, TokenSelectorFormModel>
    implements TokenSelectorFormBloc {}

class MockHorizonExplorerClientFactory extends Mock
    implements HorizonExplorerClientFactory {}

class MockHorizonExplorerApi extends Mock implements HorizonExplorerApi {}

class MockSessionStateCubit extends Mock implements SessionStateCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    registerFallbackValue(const Mainnet());

    final mockHorizonExplorerClientFactory = MockHorizonExplorerClientFactory();
    final mockHorizonExplorerApi = MockHorizonExplorerApi();

    when(() => mockHorizonExplorerClientFactory.getClient(any()))
        .thenReturn(mockHorizonExplorerApi);

    when(() => mockHorizonExplorerApi.getAssetSrc(any(), any(), any()))
        .thenAnswer((_) async => AssetSrcResponse(src: null));

    GetIt.I.registerSingleton<HorizonExplorerClientFactory>(
      mockHorizonExplorerClientFactory,
    );

    const String validSvg = '''
<?xml version="1.0" encoding="UTF-8"?>
<svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <rect width="24" height="24"/>
</svg>''';

    final Uint8List svgBytes = Uint8List.fromList(validSvg.codeUnits);
    final ByteData byteData = ByteData.sublistView(svgBytes);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message != null) {
          final String asset = utf8.decode(message.buffer
              .asUint8List(message.offsetInBytes, message.lengthInBytes));
          if (asset.endsWith('.svg')) {
            return byteData;
          }
        }
        return null;
      },
    );
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('TokenSelectorFormProvider', () {
    late List<MultiAddressBalance> mockBalances;
    late MockSessionStateCubit mockSessionCubit;

    setUp(() {
      mockBalances = [createMockBalance('PEPECASH', 'PepeCash', 100000000)];
      mockSessionCubit = MockSessionStateCubit();

      final sessionState = SessionState.success(SessionStateSuccess(
        httpConfig: const Mainnet(),
        currentAccount: null,
        redirect: false,
        decryptionKey: 'decryption-key',
        accounts: const [],
        addresses: const [],
        walletConfig: WalletConfig(
          uuid: 'test-config-uuid',
          basePath: BasePath.legacy,
          network: Network.mainnet,
          seedDerivation: SeedDerivation.bip39MnemonicToSeed,
          accountIndexEnd: 0,
        ),
      ));

      when(() => mockSessionCubit.state).thenReturn(sessionState);
      when(() => mockSessionCubit.stream)
          .thenAnswer((_) => Stream.value(sessionState));
    });

    testWidgets('should create token selector form bloc and provide actions',
        (tester) async {
      TokenSelectorFormActions? capturedActions;
      TokenSelectorFormModel? capturedState;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SessionStateCubit>.value(
            value: mockSessionCubit,
            child: TokenSelectorFormProvider(
              balances: mockBalances,
              child: (actions, state) {
                capturedActions = actions;
                capturedState = state;
                return const Text('provider child');
              },
            ),
          ),
        ),
      );

      expect(find.text('provider child'), findsOneWidget);
      expect(capturedActions, isNotNull);
      expect(capturedState, isNotNull);
      expect(capturedActions!.onTokenSelected, isNotNull);
      expect(capturedActions!.onSubmitClicked, isNotNull);
    });
  });

  group('SendFormTokenSelector', () {
    late MockTokenSelectorFormBloc mockBloc;
    late MockSessionStateCubit mockSessionCubit;
    late TokenSelectorFormActions mockActions;
    late TokenSelectorFormModel mockState;
    late List<TokenSelectorOption> mockTokenOptions;

    setUp(() {
      mockBloc = MockTokenSelectorFormBloc();
      mockSessionCubit = MockSessionStateCubit();

      mockTokenOptions = [
        createTokenSelectorOption('PEPECASH', 'PepeCash'),
        createTokenSelectorOption('XCP', 'Counterparty'),
      ];

      mockActions = TokenSelectorFormActions(
        onTokenSelected: (value) {},
        onSubmitClicked: () {},
      );

      mockState = TokenSelectorFormModel(
        balances: mockTokenOptions,
        tokenSelectorInput: const TokenSelectorInput.pure(),
        submissionStatus: FormzSubmissionStatus.initial,
      );

      when(() => mockBloc.state).thenReturn(mockState);
      when(() => mockBloc.stream).thenAnswer((_) => Stream.value(mockState));

      final sessionState = SessionState.success(SessionStateSuccess(
        httpConfig: const Mainnet(),
        currentAccount: null,
        redirect: false,
        decryptionKey: 'decryption-key',
        accounts: const [],
        addresses: const [],
        walletConfig: WalletConfig(
          uuid: 'test-config-uuid',
          basePath: BasePath.legacy,
          network: Network.mainnet,
          seedDerivation: SeedDerivation.bip39MnemonicToSeed,
          accountIndexEnd: 0,
        ),
      ));

      when(() => mockSessionCubit.state).thenReturn(sessionState);
      when(() => mockSessionCubit.stream)
          .thenAnswer((_) => Stream.value(sessionState));
    });

    Widget createTestWidget({
      TokenSelectorFormActions? actions,
      TokenSelectorFormModel? state,
      Function(TokenSelectorOption)? onTokenSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<TokenSelectorFormBloc>.value(value: mockBloc),
              BlocProvider<SessionStateCubit>.value(value: mockSessionCubit),
            ],
            child: Column(
              children: [
                if (onTokenSelected != null)
                  TokenSelectorFormSuccessHandler(
                    onTokenSelected: onTokenSelected,
                  ),
                SendFormTokenSelector(
                  actions: actions ?? mockActions,
                  state: state ?? mockState,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('should render dropdown with balances', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(HorizonRedesignDropdown<TokenSelectorOption>),
          findsOneWidget);
      expect(find.text('Select Token'), findsOneWidget);
      expect(find.byType(HorizonButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets(
        'should show disabled continue button when no token is selected',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      final button = tester.widget<HorizonButton>(find.byType(HorizonButton));
      expect(button.disabled,
          isTrue);
    });

    testWidgets('should show enabled continue button when token is selected',
        (tester) async {
      final selectedState = mockState.copyWith(
        tokenSelectorInput:
            TokenSelectorInput.dirty(value: mockTokenOptions.first),
      );

      await tester.pumpWidget(createTestWidget(state: selectedState));

      final button = tester.widget<HorizonButton>(find.byType(HorizonButton));
      expect(button.disabled, isFalse);
    });

    testWidgets('should call onSubmitClicked when continue button is pressed',
        (tester) async {
      bool submitCalled = false;
      final testActions = TokenSelectorFormActions(
        onTokenSelected: (value) {},
        onSubmitClicked: () {
          submitCalled = true;
        },
      );

      await tester.pumpWidget(createTestWidget(
          actions: testActions,
          state: mockState.copyWith(
              tokenSelectorInput:
                  TokenSelectorInput.dirty(value: mockTokenOptions.first))));

      await tester.tap(find.byType(HorizonButton));
      await tester.pump();

      expect(submitCalled, isTrue);
    });

    testWidgets('should call onTokenSelected when submission status is success',
        (tester) async {
      TokenSelectorOption? submittedOption;
      final selectedOption = mockTokenOptions.first;

      final stateController = StreamController<TokenSelectorFormModel>.broadcast();

      final initialState = mockState.copyWith(
        submissionStatus: FormzSubmissionStatus.initial,
        tokenSelectorInput: TokenSelectorInput.dirty(value: selectedOption),
      );

      final successState = mockState.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        tokenSelectorInput: TokenSelectorInput.dirty(value: selectedOption),
      );

      when(() => mockBloc.state).thenReturn(initialState);
      when(() => mockBloc.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(createTestWidget(
        state: initialState,
        onTokenSelected: (option) {
          submittedOption = option;
        },
      ));

      stateController.add(successState);
      await tester.pump();

      expect(submittedOption, equals(selectedOption));
      
      await stateController.close();
    });

    testWidgets('should display dropdown items correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final dropdown =
          find.byType(HorizonRedesignDropdown<TokenSelectorOption>);
      expect(dropdown, findsOneWidget);

      final dropdownWidget =
          tester.widget<HorizonRedesignDropdown<TokenSelectorOption>>(dropdown);
      expect(dropdownWidget.items.length, equals(mockTokenOptions.length));
    });

    testWidgets('should display selected token in dropdown', (tester) async {
      final selectedToken = mockTokenOptions.first;
      final stateWithSelection = mockState.copyWith(
        tokenSelectorInput: TokenSelectorInput.dirty(value: selectedToken),
      );

      await tester.pumpWidget(createTestWidget(state: stateWithSelection));

      final dropdown =
          tester.widget<HorizonRedesignDropdown<TokenSelectorOption>>(
              find.byType(HorizonRedesignDropdown<TokenSelectorOption>));
      expect(dropdown.selectedValue, equals(selectedToken));
    });
  });

  group('TokenSelectorFormActions', () {
    test('should create actions with required callbacks', () {
      bool tokenSelectedCalled = false;
      bool submitClickedCalled = false;

      final actions = TokenSelectorFormActions(
        onTokenSelected: (value) {
          tokenSelectedCalled = true;
        },
        onSubmitClicked: () {
          submitClickedCalled = true;
        },
      );

      expect(actions.onTokenSelected, isNotNull);
      expect(actions.onSubmitClicked, isNotNull);

      actions.onTokenSelected(createTokenSelectorOption('PEPECASH', 'PepeCash'));
      actions.onSubmitClicked();

      expect(tokenSelectedCalled, isTrue);
      expect(submitClickedCalled, isTrue);
    });
  });

  group('TokenSelectorFormBloc integration tests', () {
    late TokenSelectorFormBloc bloc;
    late List<MultiAddressBalance> balances;

    setUp(() {
      balances = [
        createMockBalance('PEPECASH', 'PepeCash', 100000000),
        createMockBalance('XCP', 'Counterparty', 100000000),
      ];
      bloc = TokenSelectorFormBloc(initialBalances: balances);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state.balances.length, equals(2));
      expect(bloc.state.tokenSelectorInput.isPure, isTrue);
      expect(bloc.state.tokenSelectorInput.value, isNull);
      expect(
          bloc.state.submissionStatus, equals(FormzSubmissionStatus.initial));
      expect(bloc.state.tokenSelectorInput.isValid, isFalse);
    });

    blocTest<TokenSelectorFormBloc, TokenSelectorFormModel>(
      'TokenSelected event updates state correctly',
      build: () => bloc,
      act: (bloc) {
        final option = bloc.state.balances.first;
        bloc.add(TokenSelected(option));
      },
      expect: () => [
        isA<TokenSelectorFormModel>()
            .having(
                (m) => m.tokenSelectorInput.value, 'selected value', isNotNull)
            .having((m) => m.tokenSelectorInput.isValid, 'valid', isTrue),
      ],
    );

    blocTest<TokenSelectorFormBloc, TokenSelectorFormModel>(
      'SubmitClicked event with selection updates submission status',
      build: () => bloc,
      act: (bloc) {
        final option = bloc.state.balances.first;
        bloc.add(TokenSelected(option));
        bloc.add(SubmitClicked());
      },
      expect: () => [
        isA<TokenSelectorFormModel>().having(
            (m) => m.tokenSelectorInput.value, 'selected value', isNotNull),
        isA<TokenSelectorFormModel>().having((m) => m.submissionStatus,
            'submission status', FormzSubmissionStatus.success),
      ],
    );
  });
}

MultiAddressBalance createMockBalance(
    String asset, String description, int total) {
  return MultiAddressBalance(
    asset: asset,
    assetLongname: null,
    total: total,
    totalNormalized: (total / 100000000).toString(),
    entries: [],
    assetInfo: AssetInfo(
      assetLongname: null,
      description: description,
      divisible: true,
      owner: null,
      locked: false,
    ),
  );
}

TokenSelectorOption createTokenSelectorOption(String name, String description) {
  final balance = createMockBalance(name, description, 100000000);
  return TokenSelectorOption(
    name: name,
    description: description,
    balance: Option.of(balance),
  );
}
