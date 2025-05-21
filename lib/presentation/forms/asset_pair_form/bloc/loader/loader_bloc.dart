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
    final [multiAddressBalance] = await Future.wait([
      _balanceRepository.getBalancesForAddresses(
          httpConfig: args.httpConfig,
          addresses: args.addresses.map((a) => a.address).toList())
    ]);

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
