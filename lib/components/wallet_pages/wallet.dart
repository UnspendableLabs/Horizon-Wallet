import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/components/wallet_pages/balance_total.dart';
import 'package:uniparty/components/wallet_pages/single_wallet_node.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/secure_storage.dart';
import 'package:uniparty/wallet_recovery/create_wallet.dart';

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
  final SecureStorage secureStorage = SecureStorage();

  WalletBloc() : super(const WalletInitial()) {
    on<WalletLoadEvent>((event, emit) => onWalletLoad(event, emit));
  }
}

Future<void> onWalletLoad(WalletLoadEvent event, Emitter<WalletState> emit) async {
  emit(const WalletLoading());

  var walletInfo = await SecureStorage().readWalletRetrieveInfo();
  List<WalletNode> walletNodes = createWallet(event.network, walletInfo!.seedHex, walletInfo.walletType);

  emit(WalletSuccess(data: walletNodes));
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
                    leadingWidth: screenSize.width / 4,
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
                    )),
                body: BlocBuilder<NetworkBloc, NetworkState>(
                  builder: (context, networkState) {
                    return Scaffold(
                        body: Container(
                            margin: EdgeInsets.symmetric(horizontal: screenSize.width / 10, vertical: screenSize.width / 20),
                            height: screenSize.height,
                            width: screenSize.width,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromRGBO(159, 194, 244, 1.0)),
                              color: const Color.fromRGBO(27, 27, 37, 1.0),
                            ),
                            child: BlocBuilder<WalletBloc, WalletState>(builder: (context, walletState) {
                              return switch (walletState) {
                                WalletInitial() => const Text('WalletInitial'),
                                WalletLoading() => const Center(child: Text('Loading...')),
                                WalletSuccess() => Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: screenSize.height,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: walletState.data.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return SingleWalletNode(
                                                network: networkState.network,
                                                walletNode: walletState.data[index],
                                                containerSize: screenSize,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSize.width / 5,
                                        decoration: const BoxDecoration(
                                          border: Border.symmetric(
                                              vertical: BorderSide(width: 1, color: Color.fromRGBO(59, 59, 66, 1.0))),
                                          color: Color.fromRGBO(27, 27, 37, 1.0),
                                        ),
                                        child: const Column(
                                          children: [
                                            BalanceTotal(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                WalletError() => Center(child: Text(walletState.message)),
                              };
                            })));
                  },
                ))));
  }
}
