import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show TaskEither;
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';

class SendFormLoader extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AddressV2> addresses;
  final BalanceRepository _balanceRepository;
  final Widget Function(List<MultiAddressBalance> balances) child;
  SendFormLoader(
      {super.key,
      required this.httpConfig,
      required this.addresses,
      required this.child})
      : _balanceRepository = GetIt.I<BalanceRepository>();

  @override
  Widget build(BuildContext context) {
    return RemoteDataTaskEitherBuilder<String, List<MultiAddressBalance>>(
      task: () => TaskEither.tryCatch(
        () => _balanceRepository.getBalancesForAddresses(
          httpConfig: httpConfig,
          addresses: addresses.map((a) => a.address).toList(),
          type: BalanceType.address,
        ),
        (error, stackTrace) => 'Failed to load balances',
      ),
      builder: (context, state, refresh) => state.fold(
        onInitial: () => const SizedBox.shrink(),
        onLoading: () => const Center(child: CircularProgressIndicator()),
        onRefreshing: (_) => const Center(child: CircularProgressIndicator()),
        onSuccess: (balances) => child(balances),
        onFailure: (failure) => const SizedBox.shrink(),
      ),
    );
  }
}