import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/network_bloc.dart';
import 'package:uniparty/bloc/wallet_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_wallet_payload.dart';
import 'package:uniparty/widgets/wallet_pages/balance_total.dart';
import 'package:uniparty/widgets/wallet_pages/single_wallet_node.dart';

class Wallet extends StatefulWidget {
  final CreateWalletPayload? payload;
  const Wallet({this.payload, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

const List<NetworkEnum> networkList = <NetworkEnum>[NetworkEnum.mainnet, NetworkEnum.testnet];

class _WalletState extends State<Wallet> {
  NetworkEnum dropdownNetwork = networkList.first;

  @override
  void initState() {
    super.initState();
    var network = BlocProvider.of<NetworkBloc>(context).state.network;
    BlocProvider.of<WalletBloc>(context).add(WalletInitEvent(payload: widget.payload, network: network));
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return BlocListener<NetworkBloc, NetworkState>(
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
                    return DropdownButton<NetworkEnum>(
                      isExpanded: true,
                      value: state.network,
                      underline: Container(),
                      iconSize: 0.0,
                      onChanged: (NetworkEnum? value) {
                        // This is called when the user selects an item.
                        BlocProvider.of<NetworkBloc>(context).add(NetworkEvent(network: value!));
                      },
                      items: networkList.map<DropdownMenuItem<NetworkEnum>>((var value) {
                        return DropdownMenuItem<NetworkEnum>(
                          value: value,
                          child: Center(
                            child: Text(
                              value.name,
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
            )));
  }
}
