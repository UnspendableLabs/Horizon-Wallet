import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_divider.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import "package:horizon/presentation/screens/dashboard/address_form/bloc/address_form_bloc.dart";
import "package:horizon/presentation/screens/dashboard/address_form/bloc/address_form_event.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import "package:horizon/remote_data_bloc/remote_data_state.dart";

class AddAddressForm extends StatefulWidget {
  final String accountUuid;
  final BuildContext? modalContext;
  const AddAddressForm(
      {super.key, required this.accountUuid, this.modalContext});

  @override
  State<AddAddressForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String error = '';

  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AddressFormBloc>().add(Reset());
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    return BlocConsumer<AddressFormBloc, RemoteDataState<Map<String, dynamic>>>(
        listener: (context, state) {
      state.whenOrNull(error: (msg) {
        setState(() {
          error = msg;
        });
      }, success: (addresses) async {
        // pop address form modal
        Navigator.of(context).pop();

        // if opened from another modal, pop that too
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.modalContext != null) {
          Navigator.of(widget.modalContext!).pop();
        }

        shell.refreshAndSelectNewAddress(
            addresses['newAddresses'].first.address, addresses['accountUuid']);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Success"),
        ));

        await Future.delayed(const Duration(milliseconds: 500));
      });
    }, builder: (context, state) {
      void handleSubmit() {
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
        }
      }

      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              enabled: state.maybeWhen(
                  loading: () => false,
                  success: (_) => false,
                  orElse: () => true),
              controller: passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              label: 'Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }

                return null;
              },
              onFieldSubmitted: (value) {
                handleSubmit();
              },
            ),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: redErrorText)),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HorizonDivider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: handleSubmit,
                            child: state.maybeWhen(
                                loading: () => const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator()),
                                success: (_) => const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator()),
                                orElse: () => const Text('SUBMIT')),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
