import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_bloc.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';

// class ComposeIssuanceEventParams {
//   final String name;
//   final int quantity;
//   final String description;
//   final bool divisible;
//   final bool lock;
//   final bool reset;

//   ComposeIssuanceEventParams({
//     required this.name,
//     required this.quantity,
//     required this.description,
//     required this.divisible,
//     required this.lock,
//     required this.reset,
//   });
// }

class UpdateIssuanceBloc extends ComposeBaseBloc<UpdateIssuanceState> {
  final AssetRepository assetRepository;
  final BalanceRepository balanceRepository;
  UpdateIssuanceBloc({
    required this.assetRepository,
    required this.balanceRepository,
  }) : super(UpdateIssuanceState(
          submitState: const SubmitInitial(),
          feeOption: FeeOption.Medium(),
          balancesState: const BalancesState.initial(),
          feeState: const FeeState.initial(),
          assetState: const AssetState.initial(),
        )) {
    // Event handlers specific to issuance
  }

  @override
  void onChangeFeeOption(ChangeFeeOption event, emit) async {
    final value = event.value;
    emit(state.copyWith(feeOption: value));
  }

  @override
  void onFetchFormData(FetchFormData event, emit) async {
    print('Fetching form data for ${event.assetName}');
    print('Current address: ${event.currentAddress?.address}');
    if (event.assetName == null || event.currentAddress == null) {
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
      assetState: const AssetState.loading(),
    ));

    print('Fetching form data for ${event.assetName}');

    final Asset asset = await assetRepository.getAsset(event.assetName!);
    print('Asset: $asset');
    print(asset.asset);
    // TODO: use this once we have the API working
    // final Balance balance = await balanceRepository.getBalanceForAddressAndAsset(event.assetName!, event.currentAddress!.address);

    final List<Balance> balances = await balanceRepository
        .getBalancesForAddress(event.currentAddress!.address);
    final Balance balance =
        balances.firstWhere((element) => element.asset == event.assetName);

    emit(state.copyWith(
      assetState: AssetState.success(asset),
      balancesState: BalancesState.success([balance]),
    ));
  }

  @override
  void onComposeTransaction(ComposeTransactionEvent event, emit) async {}

  @override
  void onFinalizeTransaction(FinalizeTransactionEvent event, emit) async {}

  @override
  void onSignAndBroadcastTransaction(
      SignAndBroadcastTransactionEvent event, emit) async {}
}
