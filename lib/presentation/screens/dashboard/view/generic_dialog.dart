import 'package:flutter/material.dart';
import 'package:horizon/presentation/colors.dart';

class GenericDialog extends StatelessWidget {
  final String title;
  final Widget body;

  const GenericDialog({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and back button
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
              // Separator
              _buildSeparator(isDarkTheme),
              // Body
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: body,
              ),
              // Separator
            ],
          ),
        ),
      ),
    );
  }
}

class DialogSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DialogSubmitButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSeparator(isDarkTheme),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                child: const Text('Submit'),
              ),
            ),
          ),
        )
      ],
    );
  }
}

Widget _buildSeparator(bool isDarkTheme) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: Divider(
      color: isDarkTheme ? greyDarkThemeUnderlineColor : greyLightThemeUnderlineColor,
      thickness: 1.0,
    ),
  );
}
