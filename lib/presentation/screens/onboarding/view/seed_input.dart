import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SeedInput extends StatefulWidget {
  final Function(String) onInputsUpdated;
  final String? errorMessage;
  final List<int>? incorrectIndexes;
  final VoidCallback? onInputChanged;
  final bool showTitle;
  final String? title;
  final String? subtitle;

  const SeedInput({
    super.key,
    required this.onInputsUpdated,
    this.errorMessage,
    this.incorrectIndexes,
    this.onInputChanged,
    this.showTitle = false,
    this.title,
    this.subtitle,
  });

  @override
  State<SeedInput> createState() => SeedInputState();
}

class SeedInputState extends State<SeedInput> {
  List<TextEditingController> controllers =
      List.generate(12, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  bool _showSeedPhrase = false;

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
    final isSmallScreen = MediaQuery.of(context).size.width < 500;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor =
        isDarkMode ? darkThemeBackgroundColor : lightThemeBackgroundColor;

    return Container(
      color: backdropBackgroundColor,
      child: Column(
        children: [
          if (widget.showTitle) ...[
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmallScreen ? 20.0 : 40.0),
              child: Column(
                children: [
                  SelectableText(
                    widget.title ?? 'Please confirm your seed phrase',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 10),
                    SelectableText(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: isDarkMode
                            ? subtitleDarkTextColor
                            : subtitleLightTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          buildInputFields(isSmallScreen, isDarkMode),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: isDarkMode
                    ? Colors.transparent
                    : transparentPurpleButtonColor,
              ),
              onPressed: () {
                setState(() {
                  _showSeedPhrase = !_showSeedPhrase;
                });
              },
              icon: Icon(
                _showSeedPhrase ? Icons.visibility_off : Icons.visibility,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              label: Text(
                _showSeedPhrase ? 'Hide Phrase' : 'Show Phrase',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (widget.errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? redErrorTextTransparentDark
                      : redErrorTextTransparentLight,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: redErrorTextColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    SelectableText(
                      widget.errorMessage!,
                      style: const TextStyle(color: redErrorTextColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget buildInputFields(bool isSmallScreen, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: 14.0, horizontal: isSmallScreen ? 20.0 : 40.0),
            child: Column(
              children: List.generate(4, (rowIndex) {
                return Row(
                  children: List.generate(3, (colIndex) {
                    final index = rowIndex * 3 + colIndex;
                    return Expanded(
                      child: buildInputField(index, isDarkMode),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget buildInputField(int index, bool isDarkMode) {
    final hasText = controllers[index].text.isNotEmpty;
    final isFocused = focusNodes[index].hasFocus;
    final isIncorrect = widget.incorrectIndexes?.contains(index) ?? false;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 105,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: hasText
              ? (isDarkMode ? inputDarkBackground : inputLightBackground)
              : (isDarkMode
                  ? darkThemeBackgroundColor
                  : lightThemeBackgroundColor),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: isIncorrect
                ? Border.all(
                    color: redErrorTextColor,
                    width: 1,
                  )
                : isFocused && hasText
                    ? const GradientBoxBorder(
                        width: 1,
                      )
                    : Border.all(
                        color: isDarkMode
                            ? inputDarkBorderColor
                            : inputLightBorderColor,
                      ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  "${index + 1}.",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: isIncorrect
                        ? redErrorTextDarkColor
                        : isDarkMode
                            ? inputDarkLabelColor
                            : inputLightLabelColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  obscureText: !_showSeedPhrase,
                  onChanged: (value) => handleInput(value, index),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(right: 20),
                    border: InputBorder.none,
                    hintText: 'Word ${index + 1}',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: isDarkMode
                          ? inputDarkLabelColor
                          : inputLightLabelColor,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: isIncorrect
                        ? redErrorTextColor
                        : isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
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

    widget.onInputChanged?.call();
    updateMnemonic();
  }

  void handleTabNavigation(int index) {
    if (index < 11) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void updateMnemonic() {
    String mnemonic =
        controllers.map((controller) => controller.text).join(' ').trim();
    widget.onInputsUpdated(mnemonic);
  }

  bool isValidMnemonic() {
    return controllers.every((controller) => controller.text.trim().isNotEmpty);
  }

  String getMnemonic() {
    return controllers
        .map((controller) => controller.text.trim())
        .where((word) => word.isNotEmpty)
        .join(' ');
  }

  void clearInputs() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      _showSeedPhrase = false;
    });
  }
}
