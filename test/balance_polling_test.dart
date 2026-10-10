import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/fairminter_repository.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/balances/balances_event.dart';

class Balances extends Mock implements BalanceRepository {}

class Accounts extends Mock implements AccountRepository {}

class Addresses extends Mock implements AddressRepository {}

class AddressTxs extends Mock implements AddressTxRepository {}

class Assets extends Mock implements AssetRepository {}

class Fairminters extends Mock implements FairminterRepository {}

void main() {
  late Balances balances;
  late BalancesBloc bloc;
  setUp(() {
    balances = Balances();
    final assets = Assets();
    final fairminters = Fairminters();
    when(() => assets.getAllValidAssetsByOwnerVerbose('address'))
        .thenAnswer((_) async => []);
    when(() => fairminters.getFairmintersByAddress('address', 'open'))
        .thenReturn(TaskEither<String, List<Fairminter>>.right([]));
    bloc = BalancesBloc(
        balanceRepository: balances,
        accountRepository: Accounts(),
        addressRepository: Addresses(),
        addressTxRepository: AddressTxs(),
        assetRepository: assets,
        fairminterRepository: fairminters,
        currentAddress: 'address');
  });
  tearDown(() async => bloc.close());

  test('slow refreshes do not overlap and subsequent refreshes still run',
      () async {
    final pending = Completer<List<Balance>>();
    when(() => balances.getBalancesForAddresses(['address']))
        .thenAnswer((_) => pending.future);
    bloc.add(Fetch());
    await pumpEventQueue();
    bloc.add(Fetch());
    bloc.add(Fetch());
    await pumpEventQueue();
    verify(() => balances.getBalancesForAddresses(['address'])).called(1);
    pending.complete([]);
    await pumpEventQueue();
    when(() => balances.getBalancesForAddresses(['address']))
        .thenAnswer((_) async => []);
    bloc.add(Fetch());
    await pumpEventQueue();
    verify(() => balances.getBalancesForAddresses(['address'])).called(1);
  });

  test('failed refresh releases the polling guard', () async {
    when(() => balances.getBalancesForAddresses(['address']))
        .thenThrow(Exception('offline'));
    bloc.add(Fetch());
    await pumpEventQueue();
    when(() => balances.getBalancesForAddresses(['address']))
        .thenAnswer((_) async => []);
    bloc.add(Fetch());
    await pumpEventQueue();
    verify(() => balances.getBalancesForAddresses(['address'])).called(2);
  });
}
