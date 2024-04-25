import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bloc/wallet_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/wallet_node.dart';
import 'package:uniparty/services/key_value_store_service.dart';
import 'package:uniparty/widgets/common/common_dialog_shape.dart';
import 'package:uniparty/widgets/wallet_pages/single_address_display.dart';

class MultiAddressDialog extends StatefulWidget {
  final List<WalletNode> walletNodes;
  final NetworkEnum network;
  const MultiAddressDialog({required this.walletNodes, required this.network, super.key});

  @override
  State<MultiAddressDialog> createState() => _MultiAddressDialogState();
}

class _MultiAddressDialogState extends State<MultiAddressDialog> {
  _MultiAddressDialogState();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(builder: (context, walletState) {
      return Dialog(
          shape: getDialogShape(),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                itemCount: widget.walletNodes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration:
                        const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.white, width: 1))),
                    child: Column(children: [
                      TextButton(
                        child: Text(widget.walletNodes[index].address,
                            style: const TextStyle(color: Colors.white, fontSize: 20, overflow: TextOverflow.visible)),
                        onPressed: () async {
                          KeyValueService keyValueService = GetIt.I.get<KeyValueService>();

                          await storeActiveWallet(widget.network, widget.walletNodes[index], keyValueService);

                          Navigator.pushNamed(
                            // ignore: use_build_context_synchronously
                            context,
                            AppRouter.walletPage,
                          );
                        },
                      ),
                      SingleAddressDisplay(address: widget.walletNodes[index].address, network: widget.network)
                    ]),
                  );
                }),
          ));
    });
  }
}
