import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_state.dart';

class ImportAddressFlow extends StatelessWidget {
  final VoidCallback onNavigateBack;

  const ImportAddressFlow({
    super.key,
    required this.onNavigateBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImportAddressPkBloc(
        walletRepository: GetIt.I.get<WalletRepository>(),
        walletService: GetIt.I.get<WalletService>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
        addressService: GetIt.I.get<AddressService>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
        importedAddressRepository: GetIt.I.get<ImportedAddressRepository>(),
        importedAddressService: GetIt.I.get<ImportedAddressService>(),
        inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
      ),
      child: _ImportAddressForm(onNavigateBack: onNavigateBack),
    );
  }
}

class _ImportAddressForm extends StatefulWidget {
  final VoidCallback onNavigateBack;

  const _ImportAddressForm({
    required this.onNavigateBack,
  });

  @override
  State<_ImportAddressForm> createState() => _ImportAddressFormState();
}

class _ImportAddressFormState extends State<_ImportAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();
  final _addressNameController = TextEditingController();
  bool _showPrivateKey = false;
  bool _toggleRecognized = false;
  ImportAddressPkFormat? _selectedFormat;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _privateKeyController.dispose();
    _addressNameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() == true &&
        _selectedFormat != null &&
        _toggleRecognized;
  }

  Future<void> _showPasswordPrompt() async {
    // Prevent multiple dialogs
    if (_isSubmitting) return;

    setState(() {
      // Clear any previous error messages when opening the prompt
      _errorMessage = null;
    });

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return HorizonPasswordPrompt(
          onPasswordSubmitted: (password) {
            Navigator.of(dialogContext).pop(password);
          },
          onCancel: () {
            Navigator.of(dialogContext).pop(null);
          },
          buttonText: 'Import',
          title: 'Enter Password',
          errorText: null,
          isLoading: false,
        );
      },
    );

    // If user cancelled or dialog was dismissed
    if (password == null) return;

    if (!mounted) return;

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    // Submit the form with the password
    if (_formKey.currentState!.validate() && _selectedFormat != null) {
      context.read<ImportAddressPkBloc>().add(
            Submit(
              wif: _privateKeyController.text,
              password: password,
              format: _selectedFormat!,
              name: _addressNameController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImportAddressPkBloc, ImportAddressPkState>(
      listener: (context, state) {
        if (state is ImportAddressPkLoading) {
          setState(() {
            _isSubmitting = true;
            // Clear error message when loading
            _errorMessage = null;
          });
        } else if (state is ImportAddressPkError) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = state.error;
          });
        } else if (state is ImportAddressPkSuccess) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Private key successfully imported'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          widget.onNavigateBack();
        } else if (state is ImportAddressPkInitial) {
          setState(() {
            _isSubmitting = false;
          });
        }
      },
      builder: (context, state) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final isLoading = state is ImportAddressPkLoading || _isSubmitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HorizonTextField(
                  controller: _addressNameController,
                  hintText: 'Address Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Address name is required";
                    }
                    return null;
                  },
                ),
                HorizonTextField(
                  controller: _privateKeyController,
                  hintText: 'Private Key',
                  obscureText: !_showPrivateKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Private key is required";
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPrivateKey
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPrivateKey = !_showPrivateKey;
                      });
                    },
                  ),
                ),
                HorizonRedesignDropdown<ImportAddressPkFormat>(
                  items: ImportAddressPkFormat.values.map((format) {
                    return DropdownMenuItem(
                      value: format,
                      child: Text(format.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFormat = value;
                      });
                    }
                  },
                  selectedValue: _selectedFormat,
                  hintText: 'Select Format',
                ),
                const SizedBox(height: 24),
                Container(
                  width: 335,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: yellow1,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: yellow1,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        textAlign: TextAlign.center,
                        'If you use this address in a non-Counterparty wallet, you risk losing your UTXO-attached asset. Please confirm you understand the risk.',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Container(
                        height: 64,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDarkMode
                                ? transparentWhite8
                                : transparentBlack8,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 11, 14, 11),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'I understand the risk',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  HorizonToggle(
                                    value: _toggleRecognized,
                                    onChanged: (_) {
                                      setState(() {
                                        _toggleRecognized = !_toggleRecognized;
                                      });
                                    },
                                    backgroundColor: yellow1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: SelectableText(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: red1,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 64,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : HorizonOutlinedButton(
                          onPressed:
                              (!_isFormValid) ? null : _showPasswordPrompt,
                          buttonText: 'Continue',
                          isTransparent: false,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
