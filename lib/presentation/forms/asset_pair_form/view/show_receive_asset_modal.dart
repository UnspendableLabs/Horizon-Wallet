import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import "../bloc/form/asset_pair_form_bloc.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:flutter_typeahead/src/common/base/types.dart';

import 'package:flutter_typeahead/src/common/search/suggestions_search.dart';
import 'package:flutter_typeahead/src/common/box/suggestions_list.dart';
import 'package:flutter_typeahead/src/common/base/suggestions_controller.dart';

class InlineTypeAhead<T> extends StatefulWidget {
  const InlineTypeAhead({
    super.key,
    required this.controller,
    required this.suggestionsController,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    this.debounce = const Duration(milliseconds: 300),
  });

  final TextEditingController controller;
  final SuggestionsController<T> suggestionsController;
  final SuggestionsCallback<T> suggestionsCallback;
  final SuggestionsItemBuilder<T> itemBuilder;
  final ValueSetter<T> onSelected;
  final Duration debounce;

  @override
  State<InlineTypeAhead<T>> createState() => _InlineTypeAheadState<T>();
}

class _InlineTypeAheadState<T> extends State<InlineTypeAhead<T>> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SuggestionsSearch<T>(
      controller: widget.suggestionsController,
      textEditingController: widget.controller,
      suggestionsCallback: widget.suggestionsCallback,
      debounceDuration: widget.debounce,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HorizonTextField(
            suffixIcon: AppIcons.searchIcon(
              context: context,
              width: 34,
              height: 34,
            ),
            controller: widget.controller,
            hintText: 'Search',
            onChanged: (term) {
              widget.suggestionsCallback(term);
            }, // SuggestionsSearch listens automatically
          ),
          const SizedBox(height: 12),
          SuggestionsList<T>(
            controller: widget.suggestionsController,
            listBuilder: (ctx, suggestions) => SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (ctx, index) => suggestions[index],
              ),
            ),
            itemBuilder: (ctx, item) => InkWell(
              onTap: () => widget.onSelected(item),
              child: widget.itemBuilder(ctx, item),
            ),
            loadingBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (ctx, err) => Padding(
                padding: const EdgeInsets.all(16), child: Text('Error: $err')),
            emptyBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No results'),
            ),
          ),
        ],
      ),
    );
  }
}

class AssetSearchDialog extends StatefulWidget {
  final Function(String) onQueryChanged;
  // final Function(AssetPairFormOption)? onAssetSelected;

  const AssetSearchDialog(
      {
      // required this.onAssetSelected,
      required this.onQueryChanged,
      super.key});

  @override
  _AssetSearchDialogState createState() => _AssetSearchDialogState();
}

class _AssetSearchDialogState extends State<AssetSearchDialog> {
  late TextEditingController _searchInputController;
  late SuggestionsController<AssetSearchResult> _suggestionsController;

  @override
  void initState() {
    super.initState();
    _suggestionsController = SuggestionsController<AssetSearchResult>();

    final initialSuggestons =
        context.read<AssetPairFormBloc>().state.displaySearchResults;

    initialSuggestons.fold(
      onInitial: () => null,
      onLoading: () => null,
      onSuccess: (suggestions) =>
          _suggestionsController.suggestions = suggestions,
      onFailure: (error) => _suggestionsController.error = error,
      onRefreshing: (suggestions) =>
          _suggestionsController.suggestions = suggestions,
    );

    _searchInputController = TextEditingController();
  }

  @override
  void dispose() {
    _suggestionsController.dispose();
    _searchInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocConsumer<AssetPairFormBloc, AssetPairFormModel>(
      // i sort of need to modify the controller based on bloc state for the initial render
      listener: (context, state) {
        switch (state.displaySearchResults) {
          case Initial():
            _suggestionsController.suggestions = null;
            _suggestionsController.isLoading = false;
            _suggestionsController.close();
            _suggestionsController.error = null;
            break;
          case Loading():
            _suggestionsController.isLoading = true;
            _suggestionsController.error = null;
            break;
          case Failure():
            _suggestionsController.isLoading = false;
            _suggestionsController.error =
                (state.searchResults as Failure).error;
            break;
          case Success():
            _suggestionsController.open(gainFocus: false);
            _suggestionsController.isLoading = false;
            _suggestionsController.suggestions =
                (state.displaySearchResults as Success).value;
            break;
          case Refreshing():
            _suggestionsController.isLoading = false;
            _suggestionsController.suggestions =
                (state.displaySearchResults as Refreshing).value;
            break;
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Blurred background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  color: Colors.transparent, // or your preferred overlay
                ),
              ),
            ),
            // Modal content on top
            Center(
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(18),
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
                        color: transparentWhite8,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InlineTypeAhead<AssetSearchResult>(
                            controller: _searchInputController,
                            suggestionsController: _suggestionsController,
                            suggestionsCallback: (term) {
                              widget.onQueryChanged(term);
                              return null;
                            },
                            onSelected: (selection) {
                              Navigator.of(context).pop(AssetPairFormOption(
                                  name: selection.name,
                                  description: selection.description,
                                  balance: const Option.none()));

                              // if (widget.onAssetSelected != null) {
                              //   widget.onAssetSelected!(AssetPairFormOption(
                              //       name: selection.name,
                              //       description: selection.description,
                              //       balance: Option.none()));
                              // }
                            },
                            itemBuilder: (context, suggestion) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: AssetSearchResultListItem(
                                  result: suggestion,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
          ],
        )
      ],
    );
  }
}

Future<AssetPairFormOption?> showReceiveAssetModal({
  required BuildContext outerContext,
  required String query,
  required ValueChanged<String> onQueryChanged,
  required ValueChanged<AssetPairFormOption>? onReceiveAssetSelected,
}) async {
  final theme = Theme.of(outerContext);
  final isDarkMode = theme.brightness == Brightness.dark;

  final controller = TextEditingController(text: query);

  controller.selection = TextSelection.fromPosition(
    TextPosition(offset: controller.text.length),
  );
  // I need to read a bloc from passed in context here

  AssetPairFormOption? response = await showDialog(
    context: outerContext,
    barrierColor: Colors.black.withOpacity(0.33),
    builder: (dialogContext) {
      return BlocProvider.value(
          value:
              BlocProvider.of<AssetPairFormBloc>(outerContext, listen: false),
          child: GestureDetector(
              onTap: () => Navigator.of(dialogContext).pop(),
              child: BlocConsumer<AssetPairFormBloc, AssetPairFormModel>(
                  listener: (context, state) {
            // no-op for now
          }, builder: (context, state) {
            return AssetSearchDialog(
              // onAssetSelected: onReceiveAssetSelected,
              onQueryChanged: onQueryChanged,
            );
          })));
    },
  );

  return response;
}
