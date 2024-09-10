import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class HorizonDialog extends StatelessWidget {
  final String title;
  final Widget body;
  final bool? includeBackButton;
  final bool? includeCloseButton;
  final Alignment? titleAlign;

  const HorizonDialog({
    super.key,
    required this.title,
    required this.body,
    this.includeBackButton = true,
    this.includeCloseButton = false,
    this.titleAlign,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 675, maxHeight: 750),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Stack(
                  children: [
                    if (includeBackButton == true)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 10.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
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
                              color:
                                  isDarkTheme ? mainTextWhite : mainTextBlack,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
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
              _buildSeparator(isDarkTheme),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HorizonDialogSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;

  const HorizonDialogSubmitButton({
    super.key,
    required this.onPressed,
    this.buttonText = 'SUBMIT',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSeparator(isDarkTheme),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: SizedBox(
                height: 45,
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  child: Text(buttonText ?? 'SUBMIT'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildSeparator(bool isDarkTheme) {
  return Padding(
    padding: const EdgeInsets.all(0.0),
    child: Divider(
      color: isDarkTheme
          ? greyDarkThemeUnderlineColor
          : greyLightThemeUnderlineColor,
      thickness: 1.0,
    ),
  );
}
