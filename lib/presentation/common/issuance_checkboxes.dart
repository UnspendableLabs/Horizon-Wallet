import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/colors.dart';

class IssuanceCheckboxes extends StatelessWidget {
  final bool? isDivisible;
  final bool? isLocked;
  final Function(bool?)? onDivisibleChanged;
  final Function(bool?)? onLockChanged;
  final bool? loading;

  const IssuanceCheckboxes(
      {super.key,
      this.isDivisible,
      this.isLocked,
      this.onDivisibleChanged,
      this.onLockChanged,
      this.loading});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          children: [
            if (isDivisible != null)
              Checkbox(
                value: isDivisible,
                onChanged: loading == true ? null : onDivisibleChanged,
              ),
            Text('Divisible',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? mainTextWhite : mainTextBlack)),
          ],
        ),
        const Row(
          children: [
            SizedBox(width: 30.0),
            Expanded(
              child: Text(
                'Whether this asset is divisible or not. Defaults to true.',
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (isLocked != null)
              Checkbox(
                value: isLocked,
                onChanged: loading == true ? null : onLockChanged,
              ),
            Text('Lock',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? mainTextWhite : mainTextBlack)),
          ],
        ),
        const Row(
          children: [
            SizedBox(width: 30.0),
            Expanded(
              child: Text(
                'Whether this issuance should lock supply of this asset forever. Defaults to false.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
