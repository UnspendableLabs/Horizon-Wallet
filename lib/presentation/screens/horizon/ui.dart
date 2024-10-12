import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/colors.dart';

class HorizonContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;
  final bool loading;

  const HorizonContinueButton({
    super.key,
    required this.onPressed,
    this.buttonText,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isDarkMode ? mediumNavyDarkTheme : royalBlueLightTheme,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  buttonText ?? 'CONTINUE',
                  style: TextStyle(
                      color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
                ),
              ],
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                buttonText ?? 'CONTINUE',
                style: TextStyle(
                    color: isDarkMode ? neonBlueDarkTheme : mainTextWhite),
              ),
            ),
    );
  }
}

class HorizonCancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;

  const HorizonCancelButton(
      {super.key, required this.onPressed, this.buttonText});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        overlayColor: noBackgroundColor,
        elevation: 0,
        backgroundColor: isDarkMode ? noBackgroundColor : lightThemeInputColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(buttonText ?? 'CANCEL',
            style: TextStyle(color: isDarkMode ? mainTextGrey : mainTextBlack)),
      ),
    );
  }
}

class HorizonDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final bool? includeBackButton;
  final bool? includeCloseButton;
  final Alignment? titleAlign;
  final void Function()? onBackButtonPressed;

  const HorizonDialog({
    super.key,
    required this.title,
    required this.body,
    this.includeBackButton = true,
    this.includeCloseButton = false,
    this.titleAlign,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    Widget dialogContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 675, maxHeight: 750),
      child: Material(
        // Provide the Material widget here
        color: isDarkTheme
            ? dialogBackgroundColorDarkTheme
            : dialogBackgroundColorLightTheme,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Your existing header and body widgets
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Stack(
                  children: [
                    // Include back button, title, and close button
                    if (includeBackButton == true)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 10.0),
                          child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => onBackButtonPressed?.call()),
                        ),
                      ),
                    Align(
                      alignment: titleAlign ?? Alignment.center,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 0.0),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (includeCloseButton == true)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, right: 10.0),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: body,
              ),
            ],
          ),
        ),
      ),
    );

    if (screenWidth < 768) {
      // Adjust for keyboard by adding bottom padding
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: dialogContent,
      );
    } else {
      return Dialog(
        child: dialogContent,
      );
    }
  }

  static void show({
    required BuildContext context,
    required Widget body,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 768) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Allows full-screen height
        builder: (BuildContext context) {
          return body;
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return body;
        },
      );
    }
  }
}

class HorizonDialogSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? textChild;
  final bool loading;

  const HorizonDialogSubmitButton({
    super.key,
    required this.onPressed,
    this.textChild = const Text('SUBMIT'),
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HorizonDivider(),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: SizedBox(
                height: 45,
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : onPressed,
                  child: loading
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              textChild != null
                                  ? textChild!
                                  : const SizedBox.shrink()
                            ],
                          ),
                        )
                      : textChild,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HorizonDropdownMenu<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? label;
  final TextEditingController? controller;
  final T? selectedValue;
  final Icon? icon;
  final double? borderRadius;
  final bool enabled;
  final String Function(T?)? displayStringForOption;

  const HorizonDropdownMenu({
    super.key,
    required this.items,
    required this.onChanged,
    this.label,
    this.controller,
    this.selectedValue,
    this.icon,
    this.borderRadius,
    this.enabled = true,
    this.displayStringForOption,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        enabled: enabled,
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<T>(
            isExpanded: true,
            value: selectedValue ?? items.first.value,
            onChanged: enabled ? onChanged : null,
            items: items,
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            icon: icon,
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((DropdownMenuItem<T> item) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    displayStringForOption?.call(item.value) ??
                        item.value.toString(),
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  HorizonDropdownMenu<T> copyWith({bool? enabled}) {
    return HorizonDropdownMenu<T>(
      items: items,
      onChanged: onChanged,
      label: label,
      controller: controller,
      selectedValue: selectedValue,
      icon: icon,
      borderRadius: borderRadius,
      enabled: enabled ?? this.enabled,
      displayStringForOption: displayStringForOption,
    );
  }
}

DropdownMenuItem<String> buildDropdownMenuItem(
    String value, String displayText) {
  return DropdownMenuItem<String>(
    value: value,
    child: MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      onHover: (_) {},
      child: Text(displayText,
          style: const TextStyle(fontWeight: FontWeight.normal)),
    ),
  );
}

class HorizonTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final bool? enabled;

  const HorizonTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.obscureText,
    this.enableSuggestions,
    this.autocorrect,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    // the use of Expanded here requires this text field to be a child of a column, row,  or flex widget
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        obscureText: obscureText ?? false,
        enableSuggestions: enableSuggestions ?? false,
        autocorrect: autocorrect ?? false,
        enabled: enabled ?? true,
        decoration: InputDecoration(
          labelText: label,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class HorizonTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? suffix;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final String? initialValue;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final Color? textColor;
  final AutovalidateMode? autovalidateMode;

  const HorizonTextFormField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.suffix,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.validator,
    this.obscureText,
    this.enableSuggestions,
    this.autocorrect,
    this.keyboardType,
    this.textCapitalization,
    this.inputFormatters,
    this.enabled,
    this.initialValue,
    this.floatingLabelBehavior,
    this.textColor,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled == false) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      final fillColor = isDarkMode
          ? dialogBackgroundColorDarkTheme
          : dialogBackgroundColorLightTheme;
      return InputDecorator(
        decoration: InputDecoration(
          fillColor: fillColor,
          labelText: label,
          suffix: suffix,
        ),
        child: obscureText == true
            ? Text(
                '•' * (controller?.text.length ?? 0),
                style: TextStyle(
                  fontSize: 16,
                  color:
                      textColor ?? (isDarkMode ? mainTextWhite : mainTextBlack),
                ),
              )
            : SelectableText(
                controller?.text ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      textColor ?? (isDarkMode ? mainTextWhite : mainTextBlack),
                ),
              ),
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled ?? true,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      obscureText: obscureText ?? false,
      enableSuggestions: enableSuggestions ?? false,
      autocorrect: autocorrect ?? false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        floatingLabelBehavior:
            floatingLabelBehavior ?? FloatingLabelBehavior.auto,
        labelText: label,
        suffix: suffix,
      ),
      style: const TextStyle(
        fontSize: 16,
      ),
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
    );
  }

  //  create a copy with updated properties
  HorizonTextFormField copyWith({bool? enabled}) {
    return HorizonTextFormField(
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      suffix: suffix,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      obscureText: obscureText,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      enabled: enabled ?? this.enabled,
      initialValue: initialValue,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
    );
  }
}

class HorizonDivider extends StatelessWidget {
  final double? thickness;
  const HorizonDivider({super.key, this.thickness = 1.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(
        thickness: thickness,
      ),
    );
  }
}
