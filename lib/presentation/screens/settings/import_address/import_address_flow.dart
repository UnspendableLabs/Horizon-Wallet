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

class ImportAddressFlow extends StatefulWidget {
  final VoidCallback onNavigateBack;

  const ImportAddressFlow({
    super.key,
    required this.onNavigateBack,
  });

  @override
  State<ImportAddressFlow> createState() => _ImportAddressFlowState();
}

class _ImportAddressFlowState extends State<ImportAddressFlow> {
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();
  final _addressNameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  ImportAddressPkFormat? _selectedFormat;
  bool _showPrivateKey = false;
  bool _toggleRecognized = false;

  @override
  void dispose() {
    _privateKeyController.dispose();
    _addressNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() == true &&
        _selectedFormat != null &&
        _toggleRecognized;
  }

  void _showPasswordPrompt(BuildContext context, bool isLoading) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          BlocListener<ImportAddressPkBloc, ImportAddressPkState>(
        listener: (context, state) {
          if (state is ImportAddressPkSuccess) {
            Navigator.of(context).pop();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Private key successfully imported'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              widget.onNavigateBack();
            }
          } else if (state is ImportAddressPkError) {
            setState(() {
              _error = state.error;
            });
          }
        },
        child: HorizonPasswordPrompt(
          onPasswordSubmitted: (password) {
            if (_formKey.currentState!.validate() && _selectedFormat != null) {
              context.read<ImportAddressPkBloc>().add(
                    Submit(
                      wif: _privateKeyController.text,
                      password: password,
                      format: _selectedFormat!,
                      name: _addressNameController.text,
                    ),
                  );
              Navigator.of(context).pop();
            }
          },
          onCancel: () {
            setState(() {
              _error = null;
            });
            Navigator.of(context).pop();
          },
          buttonText: 'Import',
          title: 'Enter Password',
          errorText: _error,
          isLoading: isLoading,
        ),
      ),
    );
  }

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
      child: BlocConsumer<ImportAddressPkBloc, ImportAddressPkState>(
        listener: (context, state) {
          if (state is ImportAddressPkError) {
            setState(() {
              _error = state.error;
            });
          } else if (state is ImportAddressPkSuccess) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Private key successfully imported'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              widget.onNavigateBack();
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is ImportAddressPkLoading;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  // const SizedBox(height: 10),
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
                  // const SizedBox(height: 10),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please be careful when importing private keys:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildWarningPoint(
                          '• Keep your private key secure',
                          'Never share it with anyone',
                        ),
                        const SizedBox(height: 8),
                        _buildWarningPoint(
                          '• Verify the source',
                          'Only import keys from trusted sources',
                        ),
                        const SizedBox(height: 8),
                        _buildWarningPoint(
                          '• Check your surroundings',
                          'Make sure no one can see your screen',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 64,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            isDarkMode ? transparentWhite8 : transparentBlack8,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                          child: Row(
                            children: [
                              Icon(
                                Icons.key,
                                size: 24,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Import',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
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
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: red1,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 64,
                    child: HorizonOutlinedButton(
                      onPressed: (isLoading || !_isFormValid)
                          ? null
                          : () => _showPasswordPrompt(context, isLoading),
                      buttonText: 'Continue',
                      isTransparent: false,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarningPoint(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
        ),
      ],
    );
  }
}
