import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import "../bloc/form/asset_pair_form_bloc.dart";

import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class AssetSearchResultListItem extends StatelessWidget {
  final AssetSearchResult result;
  const AssetSearchResultListItem({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final appIcons = AppIcons();
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return Row(
      children: [
        appIcons.assetIcon(
          httpConfig: session.httpConfig,
          context: context,
          assetName: result.name,
          description: result.description,
          width: 34,
          height: 34,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            // Text(
            //   "Balance: ${result.totalNormalized}",
            //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
            //         fontWeight: FontWeight.w500,
            //       ),
            // ),
          ],
        )
      ],
    );
  }
}

Future<dynamic> showReceiveAssetModal({
  required BuildContext context,
  required String query,
  required ValueChanged<String> onQueryChanged,
}) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  final controller = TextEditingController(text: query);

  controller.selection = TextSelection.fromPosition(
    TextPosition(offset: controller.text.length),
  );
  // I need to read a bloc from passed in context here

  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.33),
    builder: (dialogContext) {
      return BlocProvider.value(
          value: BlocProvider.of<AssetPairFormBloc>(context, listen: false),
          child: GestureDetector(
            onTap: () {
              Navigator.of(dialogContext).pop();
            },
            child: Material(
              type: MaterialType.transparency,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // absorb inside tap
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 480, minWidth: 200),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: GradientBoxBorder(context: context, width: 1),
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HorizonTextField(
                              suffixIcon: AppIcons.searchIcon(
                                context: context,
                                width: 34,
                                height: 34,
                              ),
                              hintText: "Search",
                              controller: controller,
                              onChanged: (value) {
                                onQueryChanged(value);
                              },
                            ),
                            BlocBuilder<AssetPairFormBloc, AssetPairFormModel>(
                                builder: (context, state) {
                              return switch (state.searchResults) {
                                Failure() => const Center(child: Text("Error")),
                                Initial() => const Center(
                                    child: CircularProgressIndicator()),
                                Loading() => const Center(
                                    child: CircularProgressIndicator()),
                                Success(value: var value) => ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: value.length,
                                    itemBuilder: (context, index) =>
                                        AssetSearchResultListItem(
                                      result: value[index],
                                    ),
                                  ),
                                Refreshing(value: var value) =>
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: value.length,
                                    itemBuilder: (context, index) =>
                                        AssetSearchResultListItem(
                                      result: value[index],
                                    ),
                                  )
                              };
                            })
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
    },
  );
}
