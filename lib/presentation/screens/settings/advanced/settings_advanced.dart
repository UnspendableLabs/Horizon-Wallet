import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import "./bloc/settings_advanced_bloc.dart";

import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';

class AsyncExample extends StatelessWidget {
  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    return 'Hello from the future!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Async Builder Example")),
      body: Center(
        child: FutureBuilder<String>(
          future: fetchData(),
          builder: (context, snapshot) {
            // While waiting for the future
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            // If the future completes with error
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // If the future completes with data
            if (snapshot.hasData) {
              return Text('Data: ${snapshot.data}');
            }

            // Default case (shouldn't usually reach here)
            return Text('No data');
          },
        ),
      ),
    );
  }
}

class SettingsAdvancedProvider extends StatelessWidget {
  WalletConfigRepository _walletConfigRepository;
  Widget child;

  SettingsAdvancedProvider({
    super.key,
    required this.child,
    WalletConfigRepository? walletConfigRepository,
  }) : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>();
  @override
  Widget build(BuildContext context) {
    // TODO: not sure i really like FutureBuilder
    return FutureBuilder(
        future: _walletConfigRepository.getCurrent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // TODO: not sure
          if (snapshot.hasError) {
            throw Exception("invariant");
          }

          if (snapshot.hasData) {
            return BlocProvider(
              create: (context) =>
                  SettingsAdvancedBloc(walletConfig: snapshot.data!),
              child: child,
            );
          }
          return SizedBox.shrink();
        });
  }
}

class SettingsAdvanced extends StatelessWidget {
  const SettingsAdvanced({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsAdvancedBloc, SettingsAdvancedState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            children: [
              Text(state.inferredImportFormat
                  .map((format) => format.name)
                  .getOrElse(() => "custom"))
              // SettingsItem(
              //   title: 'Wallet Type',
              //   onTap: () {
              //     // no op
              //   },
              //   trailing: SizedBox(
              //     width: 120,
              //     height: 40,
              //     child: ValueChangeObserver(
              //         defaultValue: Network.mainnet,
              //         cacheKey: SettingsKeys.network.toString(),
              //         builder: (context, value, _) {
              //           return HorizonRedesignDropdown<String>(
              //             useModal: true,
              //             onChanged: (value) {
              //               Option.fromNullable(value)
              //   jlatMap(NetworkX.fromString)
              //                   .fold(() {
              //                 print("TODO: invariant logging");
              //               }, (Network network) {
              //                 context.read<SessionStateCubit>().onNetworkChanged(
              //                     network,
              //                     () =>
              //                         widget._settingsRepository.setNetwork(network));
              //               });
              //             },
              //             items: Network.values
              //                 .map((network) => DropdownMenuItem<String>(
              //                       value: network.name,
              //                       child: Text(
              //                         network.name, // or a prettier label if desired
              //                         textAlign: TextAlign.center,
              //                       ),
              //                     ))
              //                 .toList(),
              //             selectedValue: widget._settingsRepository.network.name,
              //             hintText: 'Select timeout',
              //           );
              //         }),
              //   ),
              // ),
            ],
          );
        });
    return const Center(
      child: Text("Advanced settings"),
    );
  }
}
