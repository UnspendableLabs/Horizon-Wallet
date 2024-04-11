import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/secure_storage.dart';

class NetworkEvent {
  final String network;
  NetworkEvent({required this.network});
}

class NetworkState {
  final String network;
  NetworkState({required this.network});
}

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(NetworkState(network: MAINNET)) {
    on<NetworkEvent>((event, emit) {
      emit(NetworkState(network: event.network));
    });
  }
}

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
  final WalletRetrieveInfo data;
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
  final SecureStorage secureStorage = SecureStorage();

  WalletBloc() : super(WalletInitial()) {
    on<WalletLoadEvent>((event, emit) => onWalletLoad(event, emit));
  }
}

Future<void> onWalletLoad(WalletLoadEvent event, Emitter<WalletState> emit) async {
  // ignore: prefer_const_constructors
  emit(WalletLoading());
  await Future.delayed(Duration(seconds: 2));
  emit(WalletSuccess(data: WalletRetrieveInfo(seedHex: 'seedHex', walletType: event.network)));
}

class Wallet extends StatefulWidget {
  final WalletRetrieveInfo? payload;

  const Wallet({this.payload, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

const List<String> networkList = <String>[MAINNET, TESTNET];

class _WalletState extends State<Wallet> {
  String dropdownNetwork = networkList.first;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return MultiBlocProvider(
        providers: [
          BlocProvider<NetworkBloc>(
            create: (BuildContext context) => NetworkBloc(),
          ),
          BlocProvider<WalletBloc>(
            create: (BuildContext context) {
              var walletBloc = WalletBloc();
              var network = BlocProvider.of<NetworkBloc>(context).state.network;
              walletBloc.add(WalletLoadEvent(network: network));
              return walletBloc;
            },
          ),
        ],
        child: BlocListener<NetworkBloc, NetworkState>(
            listenWhen: (previous, current) => previous.network != current.network,
            listener: (context, state) {
              BlocProvider.of<WalletBloc>(context).add(WalletLoadEvent(network: state.network));
            },
            child: Scaffold(
                appBar: AppBar(
                    title: const Text(
                      'UNIPARTY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    backgroundColor: Colors.black,
                    leading: BlocBuilder<NetworkBloc, NetworkState>(
                      builder: (context, state) {
                        return DropdownButton(
                          isExpanded: true,
                          value: state.network,
                          underline: Container(),
                          iconSize: 0.0,
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            BlocProvider.of<NetworkBloc>(context).add(NetworkEvent(network: value!));
                          },
                          items: networkList.map<DropdownMenuItem<String>>((var value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Center(
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                    // leadingWidth: screenSize.width / 4,
                    // leading: DropdownButton(
                    //   isExpanded: true,
                    //   value: dropdownNetwork,
                    //   underline: Container(),
                    //   iconSize: 0.0,
                    //   onChanged: (String? value) {
                    //     // This is called when the user selects an item.
                    //     setState(() {
                    //       dropdownNetwork = value!;
                    //     });
                    //   },
                    //   items: networkList.map<DropdownMenuItem<String>>((var value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Center(
                    //         child: Text(
                    //           value,
                    //           textAlign: TextAlign.center,
                    //         ),
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),
                    ),
                body: BlocBuilder<NetworkBloc, NetworkState>(
                  builder: (context, state) {
                    return BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
                      return switch (state) {
                        WalletInitial() => Text('WalletInitial'),
                        WalletLoading() => Text('WalletLoading'), 
                        WalletSuccess() => Text('WalletSuccess ${state.data.walletType}'),
                        WalletError() => Text('WalletError'),
                      };
                    });
                  },
                ))));
    // body: WalletContainer(payload: widget.payload, network: dropdownNetwork));
  }
}
