import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class SeedInput extends StatefulWidget {
  final Function(String) onInputsUpdated;
  final String? errorMessage;
  final List<int>? incorrectIndexes;
  final VoidCallback? onInputChanged;
  final bool showTitle;
  final String? title;

  const SeedInput({
    super.key,
    required this.onInputsUpdated,
    this.errorMessage,
    this.incorrectIndexes,
    this.onInputChanged,
    this.showTitle = false,
    this.title,
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
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backdropBackgroundColor = isDarkMode
        ? darkThemeBackgroundColor
        : lightThemeBackgroundColorTopGradiant;

    return Container(
      color: backdropBackgroundColor,
      child: Column(
        children: [
          if (widget.showTitle) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                textAlign: TextAlign.center,
                widget.title ?? 'Please confirm your seed phrase',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
          if (isSmallScreen && widget.errorMessage != null)
            Align(
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
                    const Icon(Icons.info, color: Colors.red),
                    const SizedBox(width: 4),
                    SelectableText(
                      widget.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: isSmallScreen
                ? SingleChildScrollView(
                    child: buildInputFields(isSmallScreen, isDarkMode),
                  )
                : buildInputFields(isSmallScreen, isDarkMode),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
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
                _showSeedPhrase ? 'Hide Seed Phrase' : 'Show Seed Phrase',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (!isSmallScreen && widget.errorMessage != null)
            Column(
              children: [
                Align(
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
                        const Icon(Icons.info, color: Colors.red),
                        const SizedBox(width: 4),
                        SelectableText(
                          widget.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildInputFields(bool isSmallScreen, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isSmallScreen) {
          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(6,
                        (index) => buildCompactInputField(index, isDarkMode)),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: List.generate(
                        6,
                        (index) =>
                            buildCompactInputField(index + 6, isDarkMode)),
                  ),
                ),
              ],
            ),
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
                              return buildInputField(index, isDarkMode);
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

  Widget buildCompactInputField(int index, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              "${index + 1}.",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                obscureText: !_showSeedPhrase,
                onChanged: (value) => handleInput(value, index),
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      isDarkMode ? inputDarkBackground : inputLightBackground,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  hintText: 'Word ${index + 1}',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode ? inputDarkLabelColor : inputLightLabelColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: widget.incorrectIndexes?.contains(index) == true
                        ? const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                            style: BorderStyle.solid)
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: widget.incorrectIndexes?.contains(index) == true
                        ? const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                            style: BorderStyle.solid)
                        : BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(int index, bool isDarkMode) {
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
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              obscureText: !_showSeedPhrase,
              onChanged: (value) => handleInput(value, index),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDarkMode ? inputDarkBackground : inputLightBackground,
                labelText: 'Word ${index + 1}',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  color:
                      isDarkMode ? inputDarkLabelColor : inputLightLabelColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: widget.incorrectIndexes?.contains(index) == true
                      ? const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                          style: BorderStyle.solid)
                      : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: widget.incorrectIndexes?.contains(index) == true
                      ? const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                          style: BorderStyle.solid)
                      : BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
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
    int nextIndex;
    if (index % 6 == 5) {
      nextIndex = index + 7 - 6;
    } else {
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
