import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/forms/base/base_form_bloc.dart';

class SendFormLoaderArgs {
  final HttpConfig httpConfig;
  final List<AddressV2> addresses;

  SendFormLoaderArgs({required this.httpConfig, required this.addresses});
}

class SendFormLoaderData {
  final List<MultiAddressBalance> balances;

  SendFormLoaderData({required this.balances});
}

class SendFormLoaderFn extends Loader<SendFormLoaderArgs, SendFormLoaderData> {
  final BalanceRepository _balanceRepository;
  SendFormLoaderFn({
    BalanceRepository? balanceRepository,
  }) : _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>();

  @override
  Future<SendFormLoaderData> load(SendFormLoaderArgs args) async {
    final [multiAddressBalance] = await Future.wait([
      _balanceRepository.getBalancesForAddresses(
        httpConfig: args.httpConfig,
        addresses: args.addresses.map((a) => a.address).toList(),
        type: BalanceType.address,
      ),
    ]);

    return SendFormLoaderData(
      balances: multiAddressBalance,
    );
  }
}

class SendFormLoaderBloc
    extends BaseFormBloc<SendFormLoaderArgs, SendFormLoaderData> {
  SendFormLoaderBloc({required SendFormLoaderFn loader})
      : super(loader: loader);
}
