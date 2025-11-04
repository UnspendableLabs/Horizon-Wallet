import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import "package:horizon/presentation/forms/base/base_form_bloc.dart";
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/http_config.dart';

class SwapFormLoaderArgs {
  final List<AddressV2> addresses;
  final HttpConfig httpConfig;
  SwapFormLoaderArgs({
    required this.addresses,
    required this.httpConfig,
  });
}

class SwapFormLoaderData {
  final List<MultiAddressBalance> balances;

  SwapFormLoaderData({required this.balances});
}

class SwapFormLoaderFn extends Loader<SwapFormLoaderArgs, SwapFormLoaderData> {
  final BalanceRepository _balanceRepository;
  SwapFormLoaderFn({
    BalanceRepository? balanceRepository,
  }) : _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>();

  @override
  Future<SwapFormLoaderData> load(SwapFormLoaderArgs args) async {
    final result = await _balanceRepository
        .getBalancesForAddresses(
            httpConfig: args.httpConfig,
            addresses: args.addresses.map((a) => a.address).toList())
        .run();
    final multiAddressBalance =
        result.fold((error) => throw Exception(error), (result) => result);

    // final mockXCPBalance = MultiAddressBalance(
    //   asset: "XCP",
    //   total: 10000000000,
    //   totalNormalized: "100",
    //   assetLongname: "Counterparty",
    //   entries: [
    //     MultiAddressBalanceEntry(
    //       address: args.addresses.first.address,
    //       quantityNormalized: "100",
    //       quantity: 10000000000,
    //     )
    //   ],
    //   assetInfo: AssetInfo(
    //     assetLongname: "Counterparty",
    //     description: "Counterparty Asset",
    //     divisible: true,
    //     owner: null,
    //     locked: false,
    //   ),
    // );
    //
    // final mockGerperBalance = MultiAddressBalance(
    //   asset: "GERPER",
    //   total: 100,
    //   totalNormalized: "100",
    //   assetLongname: "GERPER",
    //   entries: [
    //     MultiAddressBalanceEntry(
    //       address: args.addresses.first.address,
    //       quantityNormalized: "100",
    //       quantity: 100,
    //     )
    //   ],
    //   assetInfo: AssetInfo(
    //     assetLongname: "GERPER",
    //     description: "GERPER",
    //     divisible: false,
    //     owner: null,
    //     locked: false,
    //   ),
    // );
    //
    // multiAddressBalance.add(mockXCPBalance);

    return SwapFormLoaderData(
      balances: multiAddressBalance,
    );
  }
}

typedef SwapFormState = RemoteData<SwapFormLoaderData>;

class SwapFormLoaderBloc
    extends BaseFormBloc<SwapFormLoaderArgs, SwapFormLoaderData> {
  SwapFormLoaderBloc({
    required SwapFormLoaderFn loader,
  }) : super(loader: loader);
}
