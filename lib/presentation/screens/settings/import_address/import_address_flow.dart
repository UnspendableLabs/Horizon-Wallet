import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class ImportAddressFlow extends StatelessWidget {
  final VoidCallback onNavigateBack;

  const ImportAddressFlow({
    super.key,
    required this.onNavigateBack,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return BlocProvider(
      create: (context) => ImportAddressPkBloc(
        httpConfig: session.httpConfig,
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
        final isLoading = state is ImportAddressPkLoading || _isSubmitting;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  suffixIcon: AppIcons.iconButton(
                    context: context,
                    icon: !_showPrivateKey
                        ? AppIcons.eyeClosedIcon(
                            context: context,
                            width: 24,
                            height: 24,
                          )
                        : AppIcons.eyeOpenIcon(
                            context: context,
                            width: 24,
                            height: 24,
                          ),
                    onPressed: () {
                      setState(() {
                        _showPrivateKey = !_showPrivateKey;
                      });
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),
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
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
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
                        AppIcons.warningHexIcon(height: 48, width: 48),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 170,
                          child: Text(
                            'Before you continue',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: yellow1,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          textAlign: TextAlign.center,
                          'If you use this address in a non-Counterparty wallet, you risk losing your UTXO-attached asset. Please confirm you understand the risk.',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context)
                                      .inputDecorationTheme
                                      .outlineBorder
                                      ?.color ??
                                  transparentBlack8,
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                    HorizonToggle(
                                      value: _toggleRecognized,
                                      onChanged: (_) {
                                        setState(() {
                                          _toggleRecognized =
                                              !_toggleRecognized;
                                        });
                                      },
                                      type: HorizonToggleType.warning,
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
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : HorizonButton(
                          variant: ButtonVariant.green,
                          disabled: !_isFormValid,
                          onPressed: _showPasswordPrompt,
                          child: TextButtonContent(value: "Continue"),
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
