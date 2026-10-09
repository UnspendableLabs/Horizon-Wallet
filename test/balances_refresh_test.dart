import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/usecases/get_balances_by_addresses.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_state.dart';

class MockUseCase extends Mock implements GetBalancesByAddressesUseCase {}

class MockCache extends Mock implements CacheProvider {}

void main() {
  setUpAll(() => registerFallbackValue(GetBalancesByAddressesParams(
      httpConfig: HttpConfig.mainnet(), addresses: const ['address'])));
  late MockUseCase useCase;
  late MockCache cache;
  late BalancesBloc bloc;
  setUp(() {
    useCase = MockUseCase();
    cache = MockCache();
    when(() => cache.getValue<dynamic>(any())).thenReturn(['BTC', 'XCP']);
    bloc = BalancesBloc(
        getBalancesByAddressesUseCase: useCase,
        httpConfig: HttpConfig.mainnet(),
        addresses: ['address'],
        cacheProvider: cache);
  });
  tearDown(() async {
    await bloc.close();
  });

  test('unchanged balances finish reloading', () async {
    when(() => useCase.call(any()))
        .thenReturn(TaskEither.right(<MultiAddressBalance>[]));
    final states = <BalancesState>[];
    final subscription = bloc.stream.listen(states.add);
    bloc.add(Fetch());
    await pumpEventQueue();
    bloc.add(Fetch());
    await pumpEventQueue();
    expect(states, [
      const BalancesState.loading(),
      BalancesState.complete(Result.ok([], ['BTC', 'XCP'])),
      BalancesState.reloading(Result.ok([], ['BTC', 'XCP'])),
      BalancesState.complete(Result.ok([], ['BTC', 'XCP'])),
    ]);
    await subscription.cancel();
  });

  test('coalesces concurrent polls but permits the next refresh', () async {
    final pending = Completer<Either<String, List<MultiAddressBalance>>>();
    when(() => useCase.call(any()))
        .thenReturn(TaskEither(() => pending.future));
    bloc.add(Fetch());
    await pumpEventQueue();
    bloc.add(Fetch());
    bloc.add(Fetch());
    await pumpEventQueue();
    verify(() => useCase.call(any())).called(1);
    pending.complete(Right([]));
    await pumpEventQueue();
    when(() => useCase.call(any()))
        .thenReturn(TaskEither.right(<MultiAddressBalance>[]));
    bloc.add(Fetch());
    await pumpEventQueue();
    verify(() => useCase.call(any())).called(1);
  });

  test('metadata-only changes remain current in subsequent reloads', () async {
    MultiAddressBalance balance(String owner) => MultiAddressBalance(
        asset: 'TOKEN',
        assetLongname: null,
        total: 1,
        totalNormalized: '1',
        entries: [],
        assetInfo: AssetInfo(
            assetLongname: null,
            description: '',
            divisible: false,
            owner: owner,
            locked: false));
    final oldBalance = balance('old');
    final newBalance = balance('new');
    when(() => useCase.call(any())).thenReturn(TaskEither.right([oldBalance]));
    bloc.add(Fetch());
    await pumpEventQueue();
    when(() => useCase.call(any())).thenReturn(TaskEither.right([newBalance]));
    bloc.add(Fetch());
    await pumpEventQueue();
    final pending = Completer<Either<String, List<MultiAddressBalance>>>();
    when(() => useCase.call(any()))
        .thenReturn(TaskEither(() => pending.future));
    bloc.add(Fetch());
    await pumpEventQueue();
    final owner = bloc.state.maybeWhen(
        reloading: (result) => result.maybeWhen(
            ok: (balances, _) => balances.first.assetInfo.owner,
            orElse: () => null),
        orElse: () => null);
    expect(owner, 'new');
    pending.complete(Right([newBalance]));
    await pumpEventQueue();
  });

  test('a failed refresh releases the in-flight guard', () async {
    when(() => useCase.call(any())).thenReturn(TaskEither.left('offline'));
    bloc.add(Fetch());
    await pumpEventQueue();
    when(() => useCase.call(any()))
        .thenReturn(TaskEither.right(<MultiAddressBalance>[]));
    bloc.add(Fetch());
    await pumpEventQueue();
    expect(bloc.state, BalancesState.complete(Result.ok([], ['BTC', 'XCP'])));
  });
}
