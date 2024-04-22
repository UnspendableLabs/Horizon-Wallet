import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/bloc/network_bloc.dart';
import 'package:uniparty/bloc/transaction_bloc.dart';
import 'package:uniparty/bloc/wallet_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_wallet_payload.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/widgets/wallet_pages/send_dialog.dart';
import 'package:uniparty/widgets/wallet_pages/single_wallet_node.dart';

class Wallet extends StatefulWidget {
  final CreateWalletPayload? payload;
  const Wallet({this.payload, super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

const List<NetworkEnum> networkList = <NetworkEnum>[NetworkEnum.mainnet, NetworkEnum.testnet];

class _WalletState extends State<Wallet> {
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
          BlocProvider.of<WalletBloc>(context).add(WalletInitEvent(network: state.network));
        },
        child: BlocBuilder<NetworkBloc, NetworkState>(builder: (context, state) {
          return Scaffold(
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
                  leading: DropdownButton<NetworkEnum>(
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
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: screenSize.width / 8),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return BlocProvider<TransactionBloc>(
                                    create: (_) => TransactionBloc(),
                                    child: SendDialog(
                                      network: state.network,
                                    ));
                              });
                        },
                      ),
                    ),
                  ]),
              body: BlocBuilder<NetworkBloc, NetworkState>(
                builder: (context, networkState) {
                  return Scaffold(
                      body: Container(
                          margin: EdgeInsets.symmetric(horizontal: screenSize.width / 10, vertical: screenSize.height / 10),
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
                              WalletSuccess() =>
                                _buildWalletContainer(screenSize, walletState.activeWallet, networkState.network),
                              WalletError() => Center(child: Text(walletState.message)),
                            };
                          })));
                },
              ));
        }));
  }

  Row _buildWalletContainer(Size screenSize, WalletNode activeWallet, NetworkEnum network) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: screenSize.height,
            child: SingleWalletNode(
              network: network,
              activeWallet: activeWallet,
              width: screenSize.width / 1.25,
            ),
          ),
        ),
      ],
    );
  }


}
