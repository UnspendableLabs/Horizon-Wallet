import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_wallet_payload.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/create_wallet_service.dart';
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/services/seed_ops_service.dart';

sealed class WalletState {
  const WalletState();
}

final class WalletInitial extends WalletState {
  const WalletInitial();
}

final class WalletLoading extends WalletState {
  const WalletLoading();
}

final class WalletSuccess extends WalletState {
  final List<WalletNode> data;
  const WalletSuccess({required this.data});
}

final class WalletError extends WalletState {
  final String message;
  const WalletError({required this.message});
}

sealed class WalletEvent {}

class WalletLoadEvent extends WalletEvent {
  final NetworkEnum network;
  WalletLoadEvent({required this.network});
}

class WalletInitEvent extends WalletEvent {
  final NetworkEnum network;
  final CreateWalletPayload? payload;
  WalletInitEvent({required this.network, this.payload});
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletInitial()) {
    on<WalletInitEvent>((event, emit) => onWalletInit(event, emit));
  }
}

Future<void> onWalletInit(WalletInitEvent event, Emitter<WalletState> emit) async {
  emit(const WalletLoading());

  await Future.delayed(const Duration(seconds: 1));

  SeedOpsService seedOpsService = GetIt.I.get<SeedOpsService>();
  KeyValueService keyValueService = GetIt.I.get<KeyValueService>();

  String? walletDataJson = await keyValueService.get(STORED_WALLET_DATA_KEY);

  if (walletDataJson != null) {
    StoredWalletData walletData = StoredWalletData.deserialize(walletDataJson);

    if (event.network == NetworkEnum.mainnet) {
      emit(WalletSuccess(data: walletData.mainnetNodes));
      return;
    }

    if (event.network == NetworkEnum.testnet) {
      if (walletData.testnetNodes.isEmpty) {
        // if testnet wallet has not been initialized, create
        List<WalletNode> testnetNodes = await GetIt.I
            .get<CreateWalletService>()
            .createWallet(NetworkEnum.mainnet, walletData.seedHex, walletData.walletType);

        // store testnetNodes in secure storage
        String walletJson = StoredWalletData.serialize(StoredWalletData(
            seedHex: walletData.seedHex,
            walletType: walletData.walletType,
            mainnetNodes: walletData.mainnetNodes,
            testnetNodes: testnetNodes));

        keyValueService.set(STORED_WALLET_DATA_KEY, walletJson);
        emit(WalletSuccess(data: testnetNodes));
        return;
      }
      emit(WalletSuccess(data: walletData.testnetNodes));
      return;
    }
    return;
  }

  if (walletDataJson == null) {
    // if walletDataJson is null, then we are creating a new wallet
    if (event.payload != null) {
      // first generate the seed hex
      String seedHex = await seedOpsService.getSeedHex(event.payload!.mnemonic, event.payload!.recoveryWallet);
      WalletTypeEnum walletType = seedOpsService.getWalletType(event.payload!.recoveryWallet);

      // then create the wallet nodes for mainnet
      List<WalletNode> mainnetNodes =
          await GetIt.I.get<CreateWalletService>().createWallet(NetworkEnum.mainnet, seedHex, walletType);

      // store seedHex, walletType, mainnetNodes in secure storage
      String walletJson = StoredWalletData.serialize(
          StoredWalletData(seedHex: seedHex, walletType: walletType, mainnetNodes: mainnetNodes, testnetNodes: []));
      keyValueService.set(STORED_WALLET_DATA_KEY, walletJson);

      // set mainnetNodes state since we always initialize with mainnet
      emit(WalletSuccess(data: mainnetNodes));
      return;
    }
  }
  // any other state than the above is an error state
  emit(const WalletError(message: 'Wallet info not found'));
}
