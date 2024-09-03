import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import "package:horizon/presentation/shell/address_form/bloc/address_form_bloc.dart";
import "package:horizon/presentation/shell/address_form/bloc/address_form_event.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import "package:horizon/remote_data_bloc/remote_data_state.dart";
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage addAddressModal(
  BuildContext modalSheetContext,
  TextTheme textTheme,
  bool isDarkTheme,
  String accountUuid,
) {
  const double pagePadding = 16.0;

  return WoltModalSheetPage(
    backgroundColor: isDarkTheme
        ? dialogBackgroundColorDarkTheme
        : dialogBackgroundColorLightTheme,
    isTopBarLayerAlwaysVisible: true,
    topBarTitle: Text('Add an address',
        style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? mainTextWhite : mainTextBlack)),
    trailingNavBarWidget: IconButton(
      padding: const EdgeInsets.all(pagePadding),
      icon: const Icon(Icons.close),
      onPressed: Navigator.of(modalSheetContext).pop,
    ),
    child: Padding(
        padding: const EdgeInsets.fromLTRB(
          pagePadding,
          50,
          pagePadding,
          pagePadding,
        ),
        child: AddAddressForm(
          accountUuid: accountUuid,
        )),
  );
}

class AddAddressForm extends StatefulWidget {
  final BuildContext? modalSheetContext;
  final String accountUuid;
  const AddAddressForm(
      {super.key, this.modalSheetContext, required this.accountUuid});

  @override
  State<AddAddressForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    return BlocConsumer<AddressFormBloc, RemoteDataState<List<Address>>>(
        listener: (context, state) {
      state.whenOrNull(error: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: SelectableText(msg),
        ));
      }, success: (addresses) async {
        // update accounts in shell

        shell.refreshAndSelectNewAddress(addresses.first.address);

                                        Navigator.of(context).pop();


        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Success"),
        ));

        await Future.delayed(const Duration(milliseconds: 500));
      });
    }, builder: (context, state) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16.0), // Spacing between inputs
            HorizonTextFormField(
              controller: passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              isDarkMode: isDarkMode,
              label: 'Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Divider(
                      color: isDarkMode
                          ? greyDarkThemeUnderlineColor
                          : greyLightThemeUnderlineColor,
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              if (_formKey.currentState!.validate()) {
                                if (state == const RemoteDataState.loading()) {
                                  return;
                                }
                                String password = passwordController.text;

                                context.read<AddressFormBloc>().add(Submit(
                                      accountUuid: widget.accountUuid,
                                      password: password,
                                    ));
                                // return to dashboard if modalSheetContext is not null
                                // this will be the case on smaller screens to close the wolt bottom sheet
                                if (widget.modalSheetContext != null) {
                                  Navigator.of(widget.modalSheetContext!).pop();
                                }
                              }
                            },
                            child: state == const RemoteDataState.loading()
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator())
                                : const Text('SUBMIT'),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
