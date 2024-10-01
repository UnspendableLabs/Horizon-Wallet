import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_divider.dart';

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
                            onPressed: () => onBackButtonPressed?.call()),
                      ),
                    ),
                  Align(
                    alignment: titleAlign ?? Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 0.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isDarkTheme ? mainTextWhite : mainTextBlack,
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
                        padding: const EdgeInsets.only(top: 15.0, right: 10.0),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const HorizonDivider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: body,
            ),
          ],
        ),
      ),
    );

    if (screenWidth < 768) {
      return BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
          return dialogContent;
        },
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
        isScrollControlled: true,
        builder: (BuildContext context) => body,
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => body,
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
