import "package:horizon/presentation/forms/base/base_form_bloc.dart";
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/common/constants.dart';

class SendAssetFormLoaderArgs {
  final String assetName;
  final List<String> addresses;
  SendAssetFormLoaderArgs({
    required this.assetName,
    required this.addresses,
  });

  String show() {
    return "SendAssetFormLoaderArgs { "
        "assetName: $assetName, "
        "addresses: $addresses }";
  }
}

class SendAssetFormLoaderData {
  final MultiAddressBalance multiAddressBalance;
  final FeeEstimates feeEstimates;

  SendAssetFormLoaderData(
      {required this.multiAddressBalance, required this.feeEstimates});
}

class SendAssetFormLoader
    extends Loader<SendAssetFormLoaderArgs, SendAssetFormLoaderData> {
  final BalanceRepository balanceRepository;
  final FeeEstimatesRespository feeEstimatesRepository;
  SendAssetFormLoader({
    required this.balanceRepository,
    required this.feeEstimatesRepository,
  });

  @override
  Future<SendAssetFormLoaderData> load(SendAssetFormLoaderArgs args) async {
    final [
      multiAddressBalance as MultiAddressBalance,
      feeEstimates as FeeEstimates
    ] = await Future.wait([
      balanceRepository.getBalancesForAddressesAndAsset(
          args.addresses, args.assetName, BalanceType.address),
      feeEstimatesRepository.getFeeEstimates(),
    ]);

    return SendAssetFormLoaderData(
      multiAddressBalance: multiAddressBalance,
      feeEstimates: feeEstimates,
    );
  }
}

typedef SendAssetFormState = RemoteData<SendAssetFormLoaderData>;

class SendAssetFormLoaderBloc
    extends BaseFormBloc<SendAssetFormLoaderArgs, SendAssetFormLoaderData> {
  SendAssetFormLoaderBloc({
    required SendAssetFormLoader loader,
  }) : super(loader: loader);
}
