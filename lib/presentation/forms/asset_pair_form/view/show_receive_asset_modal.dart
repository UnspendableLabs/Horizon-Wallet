import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';

Future<dynamic> showReceiveAssetModal({
  required BuildContext context,
  required String query,
  required RemoteData<List<AssetSearchResult>> assetSearchResults,
  required ValueChanged<String> onQueryChanged,
}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  final controller = TextEditingController(text: query);

  controller.selection = TextSelection.fromPosition(
    TextPosition(offset: controller.text.length),
  );

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.33),
    builder: (context) => GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // absorb inside tap
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480, minWidth: 200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: GradientBoxBorder(context: context, width: 1),
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Search assets...",
                        ),
                        onChanged: onQueryChanged,
                      ),
                      Text(assetSearchResults.toString())
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
