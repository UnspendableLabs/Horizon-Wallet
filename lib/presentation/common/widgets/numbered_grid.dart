import 'dart:math';

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/theme_extension.dart';

class NumberedGrid extends StatelessWidget {
  final String text;
  final int wordsPerRow;
  final double borderRadius;
  final EdgeInsets itemMargin;
  final bool isSmallScreen;

  const NumberedGrid({
    super.key,
    required this.text,
    this.wordsPerRow = 3,
    this.borderRadius = 8.0,
    this.itemMargin =
        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;
    List<String> words = text.split(' ');
    int totalWords = words.length;
    int rowCount = (totalWords / wordsPerRow).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        int startIndex = rowIndex * wordsPerRow;
        int endIndex = min((rowIndex + 1) * wordsPerRow, totalWords);
        List<String> rowWords = words.sublist(startIndex, endIndex);

        return Row(
          children: rowWords.asMap().entries.map((entry) {
            int wordIndex = startIndex + entry.key;
            String word = entry.value;
            return Expanded(
              child: Container(
                margin: itemMargin,
                child: Container(
                  width: 105,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: customTheme.inputBorderColor),
                    color: customTheme.inputBackground,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          "${wordIndex + 1}.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: theme.inputDecorationTheme.hintStyle?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SelectableText(
                            word,
                            style: TextStyle(
                              fontSize: 12,
                              color: customTheme.inputTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
