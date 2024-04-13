import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/stored_wallet_data.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/key_value_store.dart';
import 'package:uniparty/wallet_recovery/create_wallet.dart';

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

class WalletLoadEvent {
  final String network;
  WalletLoadEvent({required this.network});
}

class WalletBloc extends Bloc<WalletLoadEvent, WalletState> {
  WalletBloc() : super(const WalletLoading()) {
    on<WalletLoadEvent>((event, emit) => onWalletLoad(event, emit));
  }
}

Future<void> onWalletLoad(WalletLoadEvent event, Emitter<WalletState> emit) async {
  emit(const WalletLoading());
  // reading from secure storage blocks rendering
  // delaying allows UI to update
  // Future.delayed(const Duration(milliseconds: 50));
  String? walletDataJson = await GetIt.I.get<KeyValueService>().get(STORED_WALLET_DATA_KEY);
  // String? walletDataJson = null;
  if (walletDataJson == null) {
    emit(const WalletError(message: 'Wallet info not found'));
    return;
  }

  StoredWalletData? walletData = StoredWalletData.deserialize(walletDataJson);
  List<WalletNode> walletNodes = await createWallet(event.network, walletData!.seedHex, walletData.walletType);

  emit(WalletSuccess(data: walletNodes));
}
