import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_state.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ViewAddressPkFormWrapper extends StatelessWidget {
  final String address;
  const ViewAddressPkFormWrapper({required this.address, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewAddressPkFormBloc(
          addressRepository: GetIt.I.get<AddressRepository>(),
          importedAddressRepository: GetIt.I.get<ImportedAddressRepository>(),
          addressService: GetIt.I.get<AddressService>(),
          walletRepository: GetIt.I.get<WalletRepository>(),
          accountRepository: GetIt.I.get<AccountRepository>(),
          encryptionService: GetIt.I.get<EncryptionService>(),
          walletService: GetIt.I.get<WalletService>()),
      child: ViewAddressPkForm(address: address),
    );
  }
}

class ViewAddressPkForm extends StatefulWidget {
  final String address;
  const ViewAddressPkForm({required this.address, super.key});

  @override
  State<ViewAddressPkForm> createState() => _ViewAddressPkFormState();
}

class _ViewAddressPkFormState extends State<ViewAddressPkForm> {
  final passwordFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewAddressPkFormBloc, ViewAddressPkState>(
      builder: (context, state) {
        void handleSubmit() {
          if (passwordFormKey.currentState!.validate()) {
            context.read<ViewAddressPkFormBloc>().add(ViewAddressPk(
                address: widget.address, password: passwordController.text));
          }
        }

        return state.maybeWhen(
          initial: (initial) => Form(
            key: passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HorizonUI.HorizonTextFormField(
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
                  onEditingComplete: handleSubmit,
                ),
                if (initial.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      initial.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                HorizonUI.HorizonDialogSubmitButton(
                  textChild: const Text('SUBMIT'),
                  onPressed: handleSubmit,
                )
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (success) => Form(
            key: passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HorizonUI.HorizonTextFormField(
                  label: 'Address',
                  controller: TextEditingController(text: success.address),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                HorizonUI.HorizonTextFormField(
                  label: 'Private key',
                  controller:
                      TextEditingController(text: success.privateKeyWif),
                  enabled: false,
                ),
              ],
            ),
          ),
          error: (error) => Text(error),
          orElse: () => const Text("ViewAddressPkForm"),
        );
      },
    );
  }
}
