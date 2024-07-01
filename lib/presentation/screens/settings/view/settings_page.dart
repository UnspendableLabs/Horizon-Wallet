import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/shell/bloc/shell_state.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';

import 'package:horizon/presentation/screens/settings/bloc/password_prompt_bloc.dart';
import 'package:horizon/presentation/screens/settings/bloc/password_prompt_event.dart';
import 'package:horizon/presentation/screens/settings/bloc/password_prompt_state.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _pagePadding = 16.0;

class PasswordPrompt extends StatefulWidget {
  const PasswordPrompt({ super.key });



  @override
  State<PasswordPrompt> createState() => _PasswordPromptState();

}

class _PasswordPromptState extends State<PasswordPrompt> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final  passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("pw");
    // Fill this out in the next step.
  }
}

class SettingsPage extends StatelessWidget {
  final cacheProvider = GetIt.I.get<CacheProvider>();

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

    final initialGapLimit =
        GetIt.I.get<AccountSettingsRepository>().getGapLimit(account.uuid);

    SliverWoltModalSheetPage passwordPrompt(
      BuildContext modalSheetContext,
      TextTheme textTheme,
    ) {
      return WoltModalSheetPage(
        isTopBarLayerAlwaysVisible: true,
        topBarTitle: Text('Enter password', style: textTheme.titleSmall),
        trailingNavBarWidget: IconButton(
          padding: const EdgeInsets.all(_pagePadding),
          icon: const Icon(Icons.close),
          onPressed: () {
            context
                .read<PasswordPromptBloc>()
                .add(Reset(gapLimit: initialGapLimit));

            Navigator.of(modalSheetContext).pop();
          },
        ),
        child: const Padding(
            padding: EdgeInsets.fromLTRB(
              _pagePadding,
              _pagePadding,
              _pagePadding,
              _bottomPaddingForButton,
            ),
            child: Text("password")),
      );
    }

    return BlocConsumer<PasswordPromptBloc, PasswordPromptState>(
        listener: (context, state) {
      state.whenOrNull(initial: (maybeGapLimit) {
        if (maybeGapLimit != null) {
          // TODO put in account settings repository
          Settings.setValue('${account.uuid}:gap-limit', maybeGapLimit,
              notify: true);
        }
      }, loading: (gapLimit) {
        WoltModalSheet.show<void>(
          context: context,
          onModalDismissedWithBarrierTap: () {
            context
                .read<PasswordPromptBloc>()
                .add(Reset(gapLimit: initialGapLimit));

            Navigator.of(context).pop();
          },
          pageListBuilder: (modalSheetContext) {
            final textTheme = Theme.of(context).textTheme;
            return [passwordPrompt(modalSheetContext, textTheme)];
          },
          modalTypeBuilder: (context) {
            final size = MediaQuery.sizeOf(context).width;
            if (size < 768.0) {
              return WoltModalType.bottomSheet;
            } else {
              return WoltModalType.dialog;
            }
          },
        );
      });
    }, builder: (context, state) {
      return Column(
        children: [
          Container(
            child: Expanded(
              child: SettingsScreen(
                hasAppBar: false,
                key: Key(account.uuid),
                children: [
                  SettingsGroup(title: "Address Settings", children: [
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
                        context
                            .read<PasswordPromptBloc>()
                            .add(Show(initialGapLimit: initialGapLimit));
                        // context.read<AddressesBloc>().add(Generate(
                        //       accountUuid: account.uuid,
                        //       gapLimit: value.toInt(),
                        //     ));
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 220,
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
