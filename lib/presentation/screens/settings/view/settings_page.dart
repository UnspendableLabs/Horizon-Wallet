import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    Account? account = shell.state.maybeWhen(
        success: (state) => state.accounts
            .firstWhere((account) => account.uuid == state.currentAccountUuid),
        orElse: () => null);

    if (account == null) {
      throw Exception("invariant: account is null");
    }

    return BlocBuilder<AddressesBloc, AddressesState>(
        builder: (context, state) {
      return Column(
        children: [
          Container(
            child:  Expanded(
              child: SettingsScreen(
                hasAppBar: false,
                key: Key(account.uuid),
                children: [
                  SettingsGroup(title: "Address Settings", children: [
                    // SwitchSettingsTile(
                    //   settingKey: '${account.uuid}:change',
                    //   title: 'Use change addresses',
                    //   subtitle: 'For each receive address, generate a change address',
                    //   enabledLabel: 'Enabled',
                    //   disabledLabel: 'Disabled',
                    //   leading: const Icon(Icons.change_circle),
                    //   onChange: (value) {
                    //     debugPrint('${account.uuid}-use-change: $value');
                    //   },
                    // ),
                    SliderSettingsTile(
                      title: 'Gap Limit',
                      leading: const Icon(Icons.numbers),
                      settingKey: '${account.uuid}:gap-limit',
                      defaultValue: 10,
                      min: 1,
                      max: 50,
                      step: 1,
                      // leading: Icon(Icons.volume_up),
                      decimalPrecision: 0,
                      onChange: (value) {
                        context.read<AddressesBloc>().add(Generate(
                              accountUuid: account.uuid,
                              gapLimit: value.toInt(),
                            ));
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 200,
            child: BlocBuilder<AddressesBloc, AddressesState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Text("initial"),
                  loading: () => const Text("loading"),
                  error: (error) => Text("Error: $error"),
                  success: (addresses) => ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(addresses[index].address),
                        subtitle: Text(addresses[index].index.toString()),
                      );
                    },
                  ),
                               
                );
              },
            ),
          ),
                  
                  
        ],
      );
    });
  }
}
