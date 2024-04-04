import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:uniparty/components/wallet_pages/wallet.dart';
import 'package:uniparty/components/wallet_recovery_pages/create_and_recover_page.dart';
import 'package:uniparty/redux/app_store.dart';
import 'package:uniparty/redux/models/wallet_retrieve_info_view.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPage();
}

class _StartPage extends State<StartPage> {
  // this function is called when the app launches
  Future<String?> _loadData(WalletRetrieveInfoViewModel viewModel) async {
    await viewModel.getWalletInfoAndSetState();
    return viewModel.seedHex;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, WalletRetrieveInfoViewModel>(
        converter: ((store) => WalletRetrieveInfoViewModel.fromStore(store)),
        builder: (context, viewModel) {
          return FutureBuilder(
              future: _loadData(viewModel),
              builder: (BuildContext ctx, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData) {
                  return const Wallet();
                }
                return const CreateAndRecoverPage();
              });
        });
  }
}
