import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart' as FeeOption;
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/usecase/get_fee_estimates.dart';
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
  final BitcoindService bitcoindService;

  UpdateIssuanceBloc({
    required this.assetRepository,
    required this.balanceRepository,
    required this.bitcoindService,
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
    if (event.assetName == null || event.currentAddress == null) {
      return;
    }

    emit(state.copyWith(
      balancesState: const BalancesState.loading(),
      submitState: const SubmitInitial(),
      assetState: const AssetState.loading(),
    ));

    final Asset asset;
    late FeeEstimates feeEstimates;
    late Balance balance;

    try {
      asset = await assetRepository.getAsset(event.assetName!);
    } catch (e) {
      emit(state.copyWith(assetState: AssetState.error(e.toString())));
      return;
    }

    // TODO: use this instead
    // final Balance balance = await balanceRepository.getBalanceForAddressAndAsset(event.assetName!, event.currentAddress!.address);

    try {
      final List<Balance> balances = await balanceRepository
          .getBalancesForAddress(event.currentAddress!.address);
      balance =
          balances.firstWhere((element) => element.asset == event.assetName);
    } catch (e) {
      emit(state.copyWith(balancesState: BalancesState.error(e.toString())));
      return;
    }

    try {
      feeEstimates = await GetFeeEstimates(
        targets: (1, 3, 6),
        bitcoindService: bitcoindService,
      ).call();
    } catch (e) {
      emit(state.copyWith(feeState: FeeState.error(e.toString())));
      return;
    }

    emit(state.copyWith(
      assetState: AssetState.success(asset),
      balancesState: BalancesState.success([balance]),
      feeState: FeeState.success(feeEstimates),
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
