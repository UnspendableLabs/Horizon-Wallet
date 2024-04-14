import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/create_wallet_args.dart';
import 'package:uniparty/models/wallet_node.dart';
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
  final String network;
  WalletLoadEvent({required this.network});
}

class WalletInitEvent extends WalletEvent {
  final CreateWalletPayload? payload;
  WalletInitEvent({this.payload});
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(const WalletInitial()) {
    on<WalletInitEvent>((event, emit) => onWalletInit(event, emit));
    on<WalletLoadEvent>((event, emit) => onWalletLoad(event, emit));
  }
}

Future<void> onWalletInit(WalletInitEvent event, Emitter<WalletState> emit) async {
  emit(const WalletLoading());

  String? walletDataJson = await GetIt.I.get<KeyValueService>().get(STORED_WALLET_DATA_KEY);

  if (walletDataJson == null) {
    if (event.payload != null) {
      SeedOpsService seedOpsService = GetIt.I.get<SeedOpsService>();

      String seedHex = await seedOpsService.getSeedHex(event.payload!.mnemonic, event.payload!.recoveryWallet);
      WalletTypeEnum walletType = seedOpsService.getWalletType(event.payload!.recoveryWallet);
      print('seedHex $seedHex walletType $walletType');

      
      emit(const WalletSuccess(data: []));

      return;
      // String walletType = event.payload!.recoveryWallet;
    }
    emit(const WalletError(message: 'Wallet info not found'));

    return;
  }

  await Future.delayed(const Duration(seconds: 2));

  emit(const WalletSuccess(data: []));
}

Future<void> onWalletLoad(WalletLoadEvent event, Emitter<WalletState> emit) async {
  emit(const WalletLoading());

  await Future.delayed(const Duration(seconds: 2));

  emit(const WalletSuccess(data: []));
}

// Future<void> onWalletLoad(WalletLoadEvent event, Emitter<WalletState> emit) async {
//   emit(const WalletLoading());
//   // reading from secure storage blocks rendering
//   // delaying allows UI to update
//   // Future.delayed(const Duration(milliseconds: 50));
//   String? walletDataJson = await GetIt.I.get<KeyValueService>().get(STORED_WALLET_DATA_KEY);
//   print('read? $walletDataJson');
//   // String? walletDataJson = null;
//   if (walletDataJson == null) {
//     emit(const WalletError(message: 'Wallet info not found'));
//     return;
//   }

//   StoredWalletData? walletData = StoredWalletData.deserialize(walletDataJson);
//   List<WalletNode> walletNodes = await createWallet(event.network, walletData!.seedHex, walletData.walletType);

//   emit(WalletSuccess(data: walletNodes));
// }
