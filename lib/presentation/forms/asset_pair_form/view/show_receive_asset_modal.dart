import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
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
            controller: widget.controller,
            hintText: 'Search',
            onChanged: (term) {
              widget.suggestionsCallback(term);
            }, // SuggestionsSearch listens automatically
          ),
          const SizedBox(height: 12),
          SuggestionsList<T>(
            controller: widget.suggestionsController,
            // listBuilder: (ctx, items) {
            //   return ListView.builder(
            //     itemCount: items.length,
            //     itemBuilder: (ctx, index) {
            //       final widget =items[index];
            //       return widget;
            //     },
            //   );
            //
            // },
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

class CustomTypeahead<T> extends RawTypeAheadField<T> {
  const CustomTypeahead({
    super.key,
    required super.suggestionsController,
    required super.controller,
    required super.builder,
    required super.loadingBuilder,
    required super.errorBuilder,
    required super.emptyBuilder,
    required super.itemBuilder,
    required super.suggestionsCallback,
    required super.onSelected,
    required super.listBuilder,
  });
}

class AssetSearchDialog extends StatefulWidget {
  final Function(String) onQueryChanged;

  const AssetSearchDialog({required this.onQueryChanged, Key? key})
      : super(key: key);

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

        print("display search restults: ${state.displaySearchResults}\n");
        print("privileged search results: ${state.privilegedSearchResults}\n");
        print("search results: ${state.searchResults}\n");
        print("\n\n\n\n\n\n");
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
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Material(
            type: MaterialType.transparency,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
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
                          // HorizonTextField(
                          //   suffixIcon: AppIcons.searchIcon(
                          //     context: context,
                          //     width: 34,
                          //     height: 34,
                          //   ),
                          //   hintText: "Search",
                          //   controller: _searchInputController,
                          //   onChanged: (value) {
                          //     widget.onQueryChanged(value);
                          //   },
                          // ),
                          InlineTypeAhead<AssetSearchResult>(
                            controller: _searchInputController,
                            suggestionsController: _suggestionsController,
                            suggestionsCallback: (term) {
                              print("suggestins callback $term");
                              widget.onQueryChanged(term);
                            },
                            onSelected: (selection) {
                              print("selection: ${selection.name}");
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
          ),
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
          child: GestureDetector(onTap: () {
            Navigator.of(dialogContext).pop();
          }, child: BlocBuilder<AssetPairFormBloc, AssetPairFormModel>(
              builder: (context, state) {
            return AssetSearchDialog(
              onQueryChanged: (term) {
                onQueryChanged(term);
              },
            );
          })));
    },
  );
}
