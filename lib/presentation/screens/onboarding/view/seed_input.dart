import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
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

class _SeedWordController extends TextEditingController {
  bool _obscureText = false;

  set obscureText(bool value) {
    if (_obscureText != value) {
      _obscureText = value;
      notifyListeners();
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final String displayText = _obscureText ? '••••' : text;
    return TextSpan(style: style, text: displayText);
  }
}

class SeedInputState extends State<SeedInput> {
  late final List<_SeedWordController> controllers = List.generate(
    12,
    (_) => _SeedWordController(),
  );
  List<FocusNode> focusNodes = List.generate(12, (_) => FocusNode());
  bool _showSeedPhrase = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        // Trigger rebuild when focus changes
        setState(() {});
      });

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
      node.removeListener(() {}); // Remove listeners
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Column(
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 10),
                  SelectableText(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ],
            ),
          ),
        ],
        buildInputFields(isSmallScreen),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextButton.icon(
            style: Theme.of(context).textButtonTheme.style,
            onPressed: () {
              setState(() {
                _showSeedPhrase = !_showSeedPhrase;
              });
            },
            icon: Icon(
              _showSeedPhrase ? Icons.visibility_off : Icons.visibility,
            ),
            label: Text(
              _showSeedPhrase ? 'Hide Phrase' : 'Show Phrase',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        if (widget.errorMessage != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: customTheme.errorBackgroundColor,
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
    );
  }

  Widget buildInputFields(bool isSmallScreen) {
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
                      child: buildInputField(index),
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

  Widget buildInputField(int index) {
    final hasText = controllers[index].text.isNotEmpty;
    final isFocused = focusNodes[index].hasFocus;
    final isIncorrect = widget.incorrectIndexes?.contains(index) ?? false;
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: Container(
          width: 105,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: hasText
                ? customTheme.inputBackground
                : customTheme.inputBackgroundEmpty,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: isIncorrect
                  ? Border.all(
                      color: customTheme.errorColor,
                      width: 1,
                    )
                  : isFocused
                      ? const GradientBoxBorder(width: 1)
                      : Border.all(color: customTheme.inputBorderColor),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    "${index + 1}.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: isIncorrect
                          ? customTheme.errorColor
                          : theme.inputDecorationTheme.hintStyle?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: controllers[index]
                      ..obscureText = !_showSeedPhrase,
                    focusNode: focusNodes[index],
                    obscureText: false,
                    onChanged: (value) => handleInput(value, index),
                    onTap: () {
                      FocusScope.of(context).requestFocus(focusNodes[index]);
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 0),
                      border: InputBorder.none,
                      hintText: 'Word ${index + 1}',
                      hintStyle: theme.inputDecorationTheme.hintStyle,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: isIncorrect
                          ? customTheme.errorColor
                          : customTheme.inputTextColor,
                    ),
                    showCursor: true,
                  ),
                ),
              ],
            ),
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
