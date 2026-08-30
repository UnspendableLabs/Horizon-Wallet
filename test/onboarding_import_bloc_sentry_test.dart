import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/account_v2_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/presentation/common/usecase/set_mnemonic_usecase.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMnemonicService extends Mock implements MnemonicService {}

class MockAccountV2Repository extends Mock implements AccountV2Repository {}

class MockSetMnemonicUseCase extends Mock implements SetMnemonicUseCase {}

class MockWalletConfigRepository extends Mock
    implements WalletConfigRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockErrorService extends Mock implements ErrorService {}

void main() {
  late MockMnemonicService mnemonicService;
  late MockAccountV2Repository accountV2Repository;
  late MockSetMnemonicUseCase setMnemonicUseCase;
  late MockWalletConfigRepository walletConfigRepository;
  late MockSettingsRepository settingsRepository;
  late MockErrorService errorService;

  setUp(() {
    mnemonicService = MockMnemonicService();
    accountV2Repository = MockAccountV2Repository();
    setMnemonicUseCase = MockSetMnemonicUseCase();
    walletConfigRepository = MockWalletConfigRepository();
    settingsRepository = MockSettingsRepository();
    errorService = MockErrorService();
  });

  OnboardingImportBloc buildBloc() => OnboardingImportBloc(
        mnemonicService: mnemonicService,
        accountV2Repository: accountV2Repository,
        setMnemonicUseCase: setMnemonicUseCase,
        walletConfigRepository: walletConfigRepository,
        settingsRepository: settingsRepository,
        errorService: errorService,
      );

  test('reports unexpected import failures to Sentry without seed material',
      () async {
    when(() => mnemonicService.validateMnemonic(any())).thenReturn(true);
    when(() => setMnemonicUseCase.call(
          mnemonic: any(named: 'mnemonic'),
          password: any(named: 'password'),
        )).thenThrow(Exception('boom'));

    final bloc = buildBloc();
    bloc.add(MnemonicChanged(mnemonic: 'a b c d e f g h i j k l'));
    await bloc.stream.firstWhere((state) => state.walletType != null);

    bloc.add(ImportWallet(password: 'hunter2'));
    await bloc.stream.firstWhere((state) => state.importState is ImportStateError);

    final captured = verify(() => errorService.captureException(
          captureAny(),
          stackTrace: captureAny(named: 'stackTrace'),
          message: 'Unexpected wallet import failure',
          context: captureAny(named: 'context'),
        )).captured;

    expect(captured[0], isA<UnexpectedWalletImportException>());
    expect(captured[1], isA<StackTrace>());
    expect(captured[2], {
      'errorType': '_Exception',
      'walletType': WalletType.horizon.name,
    });

    // Neither the seed phrase nor the password may reach telemetry.
    final reported = '${captured[0]}${captured[2]}';
    expect(reported, isNot(contains('hunter2')));
    expect(reported, isNot(contains('a b c d e f g h i j k l')));
    expect(reported, isNot(contains('boom')));

    await bloc.close();
  });
}
