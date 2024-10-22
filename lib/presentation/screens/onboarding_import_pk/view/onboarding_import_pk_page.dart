import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_app_bar.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_event.dart';
import 'package:horizon/presentation/screens/onboarding_import_pk/bloc/onboarding_import_pk_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingImportPKPageWrapper extends StatelessWidget {
  const OnboardingImportPKPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingImportPKBloc(
              walletRepository: GetIt.I<WalletRepository>(),
              walletService: GetIt.I<WalletService>(),
              accountRepository: GetIt.I<AccountRepository>(),
              addressRepository: GetIt.I<AddressRepository>(),
              addressService: GetIt.I<AddressService>(),
              encryptionService: GetIt.I<EncryptionService>(),
              config: GetIt.I<Config>(),
            ),
        child: const OnboardingImportPKPage());
  }
}

class OnboardingImportPKPage extends StatefulWidget {
  const OnboardingImportPKPage({super.key});
  @override
  OnboardingImportPKPageState createState() => OnboardingImportPKPageState();
}

class OnboardingImportPKPageState extends State<OnboardingImportPKPage> {
  final TextEditingController _seedPhraseController =
      TextEditingController(text: "");
  final TextEditingController _importFormat =
      TextEditingController(text: ImportFormat.horizon.name);

  @override
  dispose() {
    _seedPhraseController.dispose();
    _importFormat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 768;
    final EdgeInsetsGeometry padding = isSmallScreen
        ? const EdgeInsets.all(8.0)
        : EdgeInsets.symmetric(
            horizontal: screenSize.width / 8,
            vertical: screenSize.height / 16,
          );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor =
        isDarkMode ? mediumNavyDarkTheme : lightBlueLightTheme;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;

    return Container(
      decoration: BoxDecoration(
        color: backdropBackgroundColor,
      ),
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(12),
        child: Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          body: BlocListener<OnboardingImportPKBloc, OnboardingImportPKState>(
            listener: (context, state) async {
              if (state.importState is ImportStateSuccess) {
                final shell = context.read<ShellStateCubit>();
                // reload shell to trigger redirect
                shell.initialize();
              }
            },
            child: BlocBuilder<OnboardingImportPKBloc, OnboardingImportPKState>(
                builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Scaffold(
                  backgroundColor: scaffoldBackgroundColor,
                  appBar: OnboardingAppBar(
                    isDarkMode: isDarkMode,
                    isSmallScreenWidth: isSmallScreen,
                    isSmallScreenHeight: isSmallScreen,
                    scaffoldBackgroundColor: scaffoldBackgroundColor,
                  ),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          Flexible(
                            child: state.importState == ImportStateNotAsked
                                ? PKField(pkErrorState: state.pkError)
                                : PasswordPrompt(
                                    state: state,
                                    onPressedBack: () {
                                      final shell =
                                          context.read<ShellStateCubit>();
                                      shell.onOnboarding();
                                    },
                                    onPressedContinue: (password) {
                                      context
                                          .read<OnboardingImportPKBloc>()
                                          .add(
                                              ImportWallet(password: password));
                                    },
                                    backButtonText: 'CANCEL',
                                    continueButtonText: 'LOGIN',
                                    optionalErrorWidget: state.importState
                                            is ImportStateError
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: redErrorTextTransparent,
                                                borderRadius:
                                                    BorderRadius.circular(40.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.info,
                                                      color: redErrorText),
                                                  const SizedBox(width: 4),
                                                  SelectableText(
                                                    state.importState.message,
                                                    style: const TextStyle(
                                                        color: redErrorText),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : null),
                          ),
                        ],
                      ),
                      if (state.importState is ImportStateLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class PKField extends StatefulWidget {
  final String? pkErrorState;
  const PKField({super.key, required this.pkErrorState});
  @override
  State<PKField> createState() => _PKFieldState();
}

class _PKFieldState extends State<PKField> {
  TextEditingController pkController = TextEditingController();

  String? selectedFormat = ImportFormat.horizon.name;

  @override
  void dispose() {
    pkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDarkMode ? lightNavyDarkTheme : whiteLightTheme;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: isSmallScreen ? 16 : 20),
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: pkController,
                    onChanged: (value) {
                      context
                          .read<OnboardingImportPKBloc>()
                          .add(PKChanged(pk: value));
                    },
                    onSubmitted: (value) {
                      context.read<OnboardingImportPKBloc>().add(PKSubmit(
                            pk: pkController.text,
                            importFormat: selectedFormat!,
                          ));
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode
                          ? darkThemeInputColor
                          : lightThemeInputColor,
                      labelText: 'Private Key',
                      helperText: 'Root BIP32 Extended Private Key',
                      labelStyle: TextStyle(
                        color: isDarkMode
                            ? darkThemeInputLabelColor
                            : lightThemeInputLabelColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.pkErrorState != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SelectableText(
                        widget.pkErrorState!,
                        style: const TextStyle(color: redErrorText),
                      ),
                    ),
                ],
              ),
            ),
          )),
          if (isSmallScreen) const SizedBox(height: 16),
          ImportFormatDropdown(
            onChanged: (String? newValue) {
              setState(() {
                selectedFormat = newValue;
              });
              context
                  .read<OnboardingImportPKBloc>()
                  .add(ImportFormatChanged(importFormat: newValue!));
            },
            selectedFormat: selectedFormat!,
          ),
          BackContinueButtons(
              isDarkMode: isDarkMode,
              isSmallScreenWidth: isSmallScreen,
              onPressedBack: () {
                final shell = context.read<ShellStateCubit>();
                shell.onOnboarding();
              },
              onPressedContinue: () {
                context.read<OnboardingImportPKBloc>().add(PKSubmit(
                      pk: pkController.text,
                      importFormat: selectedFormat!,
                    ));
              },
              backButtonText: 'CANCEL',
              continueButtonText: 'CONTINUE'),
        ],
      ),
    );
  }
}
