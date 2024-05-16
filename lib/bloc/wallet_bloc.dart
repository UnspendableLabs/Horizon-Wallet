import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/bitcoin_wallet_utils/create_wallet.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_wallet_payload.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/models/seed.dart';
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
  final WalletNode activeWallet;
  final List<WalletNode> allWallets;
  const WalletSuccess({required this.activeWallet, required this.allWallets});
}

final class WalletError extends WalletState {
  final String message;
  const WalletError({required this.message});
}

sealed class WalletEvent {}

class WalletInitEvent extends WalletEvent {
  final NetworkEnum network;
  final CreateWalletPayload? payload;
  WalletInitEvent({required this.network, this.payload});
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletInitial()) {
    on<WalletInitEvent>((event, emit) => _onWalletInit(event, emit));
  }
}

Future<void> _onWalletInit(WalletInitEvent event, Emitter<WalletState> emit) async {
  emit(const WalletLoading());
  try {
    await Future.delayed(const Duration(seconds: 1));

    SeedOpsService seedOpsService = GetIt.I.get<SeedOpsService>();
    KeyValueService keyValueService = GetIt.I.get<KeyValueService>();

    // attempt to retrieve the active address for the network
    WalletNode? activeWallet = await _getActiveWalletForNetwork(event.network, keyValueService);
    List<WalletNode>? walletNodes = await _getWalletNodesForNetwork(event, keyValueService);

    if (activeWallet != null && walletNodes != null) {
      emit(WalletSuccess(activeWallet: activeWallet, allWallets: walletNodes));
      return;
    }

    // if no active address exists, check to see if we have stored wallet data
    String? walletDataJson = await keyValueService.get(STORED_WALLET_DATA_KEY);

    if (walletDataJson == null) {
      // if no data is stored in secure storage, then we are creating a new wallet
      // first create and store seed hex and wallet type
      StoredWalletData walletData =
          await _createAndStoreSeedhexAndWalletType(event.payload, seedOpsService, keyValueService);

      // then create the wallet nodes for the network
      List<WalletNode> walletNodes = createWallet(event.network, walletData.seedHex, walletData.walletType);

      // store all walletNodes in secure storage
      await _storeWalletNodesForNetwork(event.network, walletNodes, keyValueService);

      WalletNode activeWallet = walletNodes[0];

      await storeActiveWallet(event.network, activeWallet, keyValueService);
      emit(WalletSuccess(activeWallet: activeWallet, allWallets: walletNodes));
      return;
    } else {
      // if wallet data is found in secure storage, deserialize
      StoredWalletData walletData = StoredWalletData.deserialize(walletDataJson);

      // get or create all the wallets for the network
      List<WalletNode> walletNodes = await _getOrCreateWalletNodesForNetwork(event, walletData, keyValueService);

      // set the active wallet
      WalletNode activeWallet = walletNodes[0];
      await storeActiveWallet(event.network, activeWallet, keyValueService);
      emit(WalletSuccess(activeWallet: activeWallet, allWallets: walletNodes));
    }
  } catch (error) {
    emit(const WalletError(message: 'Error fetching or creating wallet.'));
  }
}

Future<WalletNode?> _getActiveWalletForNetwork(NetworkEnum network, KeyValueService keyValueService) async {
  switch (network) {
    case NetworkEnum.mainnet:
      String? activeWalletJson = await keyValueService.get(ACTIVE_MAINNET_WALLET_KEY);
      return activeWalletJson != null ? WalletNode.deserialize(activeWalletJson) : null;
    case NetworkEnum.testnet:
      String? activeWalletJson = await keyValueService.get(ACTIVE_TESTNET_WALLET_KEY);
      return activeWalletJson != null ? WalletNode.deserialize(activeWalletJson) : null;
  }
}

Future<StoredWalletData> _createAndStoreSeedhexAndWalletType(
    CreateWalletPayload? payload, SeedOpsService seedOpsService, KeyValueService keyValueService) async {
  if (payload == null) {
    throw Exception('payload is null');
  }
  
  Seed seed = await seedOpsService.getSeed(payload.mnemonic, payload.recoveryWallet);
  WalletTypeEnum walletType = seedOpsService.getWalletType(payload.recoveryWallet);

  StoredWalletData storedWalletData = StoredWalletData(seedHex: seed.toHex, walletType: walletType);

  // store seedHex, walletType in secure storage
  await keyValueService.set(STORED_WALLET_DATA_KEY, StoredWalletData.serialize(storedWalletData));

  return storedWalletData;
}

Future<void> _storeWalletNodesForNetwork(
    NetworkEnum network, List<WalletNode> walletNodes, KeyValueService keyValueService) async {
  switch (network) {
    case NetworkEnum.mainnet:
      await keyValueService.set(MAINNET_WALLET_NODES_KEY, WalletNode.serializeList(walletNodes));
    case NetworkEnum.testnet:
      await keyValueService.set(TESTNET_WALLET_NODES_KEY, WalletNode.serializeList(walletNodes));
  }
}

Future<void> storeActiveWallet(NetworkEnum network, WalletNode activeWallet, KeyValueService keyValueService) async {
  switch (network) {
    case NetworkEnum.mainnet:
      await keyValueService.set(ACTIVE_MAINNET_WALLET_KEY, WalletNode.serialize(activeWallet));
    case NetworkEnum.testnet:
      await keyValueService.set(ACTIVE_TESTNET_WALLET_KEY, WalletNode.serialize(activeWallet));
  }
}

Future<List<WalletNode>?> _getWalletNodesForNetwork(WalletInitEvent event, KeyValueService keyValueService) async {
  switch (event.network) {
    case NetworkEnum.mainnet:
      String? mainnetNodesJson = await keyValueService.get(MAINNET_WALLET_NODES_KEY);
      return mainnetNodesJson != null ? WalletNode.deserializeList(mainnetNodesJson) : null;
    case NetworkEnum.testnet:
      String? testnetNodesJson = await keyValueService.get(TESTNET_WALLET_NODES_KEY);
      return testnetNodesJson != null ? WalletNode.deserializeList(testnetNodesJson) : null;
  }
}

Future<List<WalletNode>> _getOrCreateWalletNodesForNetwork(
    WalletInitEvent event, StoredWalletData walletData, KeyValueService keyValueService) async {
  List<WalletNode>? walletNodes = await _getWalletNodesForNetwork(event, keyValueService);
  if (walletNodes != null) {
    return walletNodes;
  }
  switch (event.network) {
    case NetworkEnum.mainnet:
      List<WalletNode> mainnetNodes = createWallet(event.network, walletData.seedHex, walletData.walletType);
      _storeWalletNodesForNetwork(event.network, mainnetNodes, keyValueService);
      return mainnetNodes;

    case NetworkEnum.testnet:
      List<WalletNode> testnetNodes = createWallet(event.network, walletData.seedHex, walletData.walletType);
      _storeWalletNodesForNetwork(event.network, testnetNodes, keyValueService);
      return testnetNodes;
  }
}
