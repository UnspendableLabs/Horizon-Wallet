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
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';

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
  ImportAddressPkFormat _selectedFormat = ImportAddressPkFormat.segwit;

  @override
  void dispose() {
    _privateKeyController.dispose();
    _addressNameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Import Private Key',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please be careful when importing private keys:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildWarningPoint(
                    '• Keep your private key secure',
                    'Never share it with anyone',
                  ),
                  const SizedBox(height: 12),
                  _buildWarningPoint(
                    '• Verify the source',
                    'Only import keys from trusted sources',
                  ),
                  const SizedBox(height: 12),
                  _buildWarningPoint(
                    '• Check your surroundings',
                    'Make sure no one can see your screen',
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _privateKeyController,
                    decoration: InputDecoration(
                      labelText: 'Private Key',
                      errorText: _error,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a private key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ImportAddressPkFormat>(
                    value: _selectedFormat,
                    decoration: const InputDecoration(
                      labelText: 'Address Format',
                    ),
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressNameController,
                    decoration: const InputDecoration(
                      labelText: 'Address Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Wallet Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your wallet password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ImportAddressPkBloc>().add(
                                      Submit(
                                        wif: _privateKeyController.text,
                                        password: _passwordController.text,
                                        format: _selectedFormat,
                                        name: _addressNameController.text,
                                      ),
                                    );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Import Address'),
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
