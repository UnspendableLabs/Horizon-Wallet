import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/onboarding/view/back_continue_buttons.dart';
import 'package:horizon/presentation/screens/onboarding/view/onboarding_app_bar.dart';
import 'package:horizon/presentation/screens/onboarding/view/password_prompt.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_bloc.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class OnboardingImportPage extends StatelessWidget {
  const OnboardingImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => OnboardingImportBloc(),
        child: const OnboardingImportPage_());
  }
}

class OnboardingImportPage_ extends StatefulWidget {
  const OnboardingImportPage_({super.key});
  @override
  _OnboardingImportPageState createState() => _OnboardingImportPageState();
}

class _OnboardingImportPageState extends State<OnboardingImportPage_> {
  final TextEditingController _passwordController =
      TextEditingController(text: "");
  final TextEditingController _passwordConfirmationController =
      TextEditingController(text: "");
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
          body: BlocListener<OnboardingImportBloc, OnboardingImportState>(
            listener: (context, state) async {
              if (state.importState is ImportStateSuccess) {
                final shell = context.read<ShellStateCubit>();
                // reload shell to trigger redirect
                shell.initialize();
              }
            },
            child: BlocBuilder<OnboardingImportBloc, OnboardingImportState>(
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
                                ? SeedInputFields(
                                    mnemonicErrorState: state.mnemonicError,
                                  )
                                : PasswordPrompt(
                                    passwordController: _passwordController,
                                    passwordConfirmationController:
                                        _passwordConfirmationController,
                                    state: state,
                                    onPasswordChanged: (value) {
                                      String? error = validatePassword(value,
                                          _passwordConfirmationController.text);
                                      if (error == null) {
                                        context
                                            .read<OnboardingImportBloc>()
                                            .add(PasswordChanged(
                                                password: value));
                                      } else {
                                        context
                                            .read<OnboardingImportBloc>()
                                            .add(PasswordError(error: error));
                                      }
                                    },
                                    onPasswordConfirmationChanged: (value) {
                                      String? error = validatePassword(
                                          _passwordController.text, value);
                                      if (error == null) {
                                        context
                                            .read<OnboardingImportBloc>()
                                            .add(PasswordConfirmationChanged(
                                                passwordConfirmation: value));
                                      } else {
                                        context
                                            .read<OnboardingImportBloc>()
                                            .add(PasswordError(error: error));
                                      }
                                    },
                                    onPressedBack: () {
                                      final shell =
                                          context.read<ShellStateCubit>();
                                      shell.onOnboarding();
                                    },
                                onPressedContinue: () {
                                      String? error = validatePasswordOnSubmit(
                                          _passwordController.text, _passwordConfirmationController.text);
                                      if (error == null) {
                                        context.read<OnboardingImportBloc>().add(ImportWallet());
                                      } else {
                                        context.read<OnboardingImportBloc>().add(PasswordError(error: error));
                                      }
                                    },
                                    backButtonText: 'CANCEL',
                                    continueButtonText: 'LOGIN',
                                  ),
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

class SeedInputFields extends StatefulWidget {
  final String? mnemonicErrorState;
  const SeedInputFields({super.key, required this.mnemonicErrorState});
  @override
  State<SeedInputFields> createState() => _SeedInputFieldsState();
}

class _SeedInputFieldsState extends State<SeedInputFields> {
  List<TextEditingController> controllers =
      List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  String? selectedFormat = ImportFormat.horizon.name;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          handleTabNavigation(i);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
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
          const SizedBox(height: 16),
          isSmallScreen && widget.mnemonicErrorState != null
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: redErrorTextTransparent,
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info, color: redErrorText),
                        const SizedBox(width: 4),
                        SelectableText(
                          widget.mnemonicErrorState!,
                          style: const TextStyle(color: redErrorText),
                        ),
                      ],
                    ),
                  ),
                )
              : const Text(""),
          Expanded(
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: buildInputFields(isSmallScreen, isDarkMode),
                  )
                : buildInputFields(isSmallScreen, isDarkMode),
          ),
          if (isSmallScreen) const SizedBox(height: 16),
          buildDropdownButton(isDarkMode),
          BackContinueButtons(
            isDarkMode: isDarkMode,
            isSmallScreenWidth: isSmallScreen,
            backButtonText: 'CANCEL',
            continueButtonText: 'CONTINUE',
            onPressedBack: () {
              final shell = context.read<ShellStateCubit>();
              shell.onOnboarding();
            },
            onPressedContinue: () {
              context.read<OnboardingImportBloc>().add(MnemonicSubmit(
                    mnemonic: controllers
                        .map((controller) => controller.text)
                        .join(' ')
                        .trim(),
                    importFormat: selectedFormat!,
                  ));
            },
            errorWidget: !isSmallScreen && widget.mnemonicErrorState != null
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: redErrorTextTransparent,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info, color: redErrorText),
                          const SizedBox(width: 4),
                          SelectableText(
                            widget.mnemonicErrorState!,
                            style: const TextStyle(color: redErrorText),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildInputFields(bool isSmallScreen, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isSmallScreen) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(12, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: Text(
                                  "${index + 1}. ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? mainTextWhite
                                          : mainTextBlack),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: controllers[index],
                                  focusNode: focusNodes[index],
                                  onChanged: (value) =>
                                      handleInput(value, index),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? darkThemeInputColor
                                        : lightThemeInputColor,
                                    labelText: 'Word ${index + 1}',
                                    labelStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: isDarkMode
                                            ? darkThemeInputLabelColor
                                            : lightThemeInputLabelColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(2, (columnIndex) {
                        return Expanded(
                          child: Column(
                            children: List.generate(6, (rowIndex) {
                              int index = columnIndex * 6 + rowIndex;
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        "${index + 1}. ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: isDarkMode
                                                ? mainTextWhite
                                                : mainTextBlack),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: controllers[index],
                                        focusNode: focusNodes[index],
                                        onChanged: (value) =>
                                            handleInput(value, index),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDarkMode
                                              ? darkThemeInputColor
                                              : lightThemeInputColor,
                                          labelText: 'Word ${index + 1}',
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: isDarkMode
                                                  ? darkThemeInputLabelColor
                                                  : lightThemeInputLabelColor),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildDropdownButton(bool isDarkMode) {
    final dropdownBackgroundColor =
        isDarkMode ? darkThemeInputColor : lightThemeInputColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dropdownBackgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButtonHideUnderline(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedFormat,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFormat = newValue;
                });
                context
                    .read<OnboardingImportBloc>()
                    .add(ImportFormatChanged(importFormat: newValue!));
                updateMnemonic();
              },
              dropdownColor: dropdownBackgroundColor,
              items: [
                _buildDropdownMenuItem(ImportFormat.horizon.name,
                    ImportFormat.horizon.description, dropdownBackgroundColor),
                _buildDropdownMenuItem(
                    ImportFormat.counterwallet.name,
                    ImportFormat.counterwallet.description,
                    dropdownBackgroundColor),
                _buildDropdownMenuItem(
                    ImportFormat.freewallet.name,
                    ImportFormat.freewallet.description,
                    dropdownBackgroundColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(
      String value, String description, Color backgroundColor) {
    return DropdownMenuItem<String>(
      value: value,
      child: MouseRegion(
        onEnter: (_) {},
        onExit: (_) {},
        onHover: (_) {},
        child: Text(description,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  void handleInput(String value, int index) {
    var words = value.split(RegExp(r'\s+'));
    if (words.length > 1 && index < 11) {
      for (int i = 0; i < words.length && (index + i) < 12; i++) {
        controllers[index + i].text = words[i];
        if ((index + i + 1) < 12) {
          FocusScope.of(context).requestFocus(focusNodes[index + i + 1]);
        }
      }
    }
    updateMnemonic();
  }

  void handleTabNavigation(int index) {
    int nextIndex;
    if (index % 6 == 5) {
      // Move to the next column
      nextIndex = index + 7 - 6;
    } else {
      // Move down the current column
      nextIndex = index + 1;
    }

    if (nextIndex < 12) {
      FocusScope.of(context).requestFocus(focusNodes[nextIndex]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void updateMnemonic() {
    String mnemonic =
        controllers.map((controller) => controller.text).join(' ').trim();
    context
        .read<OnboardingImportBloc>()
        .add(MnemonicChanged(mnemonic: mnemonic));
  }
}

class AddressListView extends StatelessWidget {
  final List<Address> addresses;
  final Map<Address, bool> isCheckedMap;
  final void Function(Address, bool) onCheckedChanged;

  const AddressListView({
    super.key,
    required this.addresses,
    required this.isCheckedMap,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          // physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return AddressListItem(
              address: address,
              isChecked: isCheckedMap[address] ?? false,
              onCheckedChanged: (isChecked) {
                onCheckedChanged(address, isChecked);
              },
            );
          },
        ),
      ),
    );
  }
}

class AddressListItem extends StatelessWidget {
  final Address address;
  final bool isChecked;
  final ValueChanged<bool> onCheckedChanged;

  const AddressListItem({
    super.key,
    required this.address,
    required this.isChecked,
    required this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (value) {
          onCheckedChanged(value!);
        },
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              address.address,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      // subtitle: Text(address.derivationPath),
    );
  }
}
