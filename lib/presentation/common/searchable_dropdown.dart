import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String hintText;
  final Widget Function(T) itemBuilder;
  final Widget Function(T)? selectedItemBuilder;
  final Function(T) onChanged;
  final T? selectedItem;
  final bool gradBorder;
  final EdgeInsets? itemPadding;
  final BorderRadius? cornerRadius;
  final Color? buttonBg;
  final TextStyle? buttonTextStyle;
  final TextEditingController searchController;
  final String? searchHintText;
  const SearchableDropdown(
      {super.key,
      required this.items,
      required this.hintText,
      required this.itemBuilder,
      required this.searchController,
      this.selectedItemBuilder,
      required this.onChanged,
      this.selectedItem,
      this.gradBorder = true,
      this.itemPadding,
      this.cornerRadius = const BorderRadius.all(Radius.circular(18)),
      this.buttonBg,
      this.buttonTextStyle,
      this.searchHintText});

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final focusNode = FocusNode();

  OverlayEntry _createOverlayEntry() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: transparentBlack33,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 480, // Maximum width for larger screens
                        minWidth: 200, // Minimum width for smaller screens
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: widget.gradBorder
                                ? GradientBoxBorder(
                                    context: context,
                                    width: 1,
                                  )
                                : Border.all(
                                    color: isDarkMode
                                        ? transparentWhite8
                                        : transparentBlack8,
                                    width: 1,
                                  ),
                            color: (isDarkMode
                                ? transparentWhite8
                                : transparentBlack8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 20,
                                  ),
                                  height: 56,
                                  child: HorizonTextField(
                                      suffixIcon: AppIcons.searchIcon(
                                          context: context,
                                          width: 24,
                                          height: 24),
                                      controller: widget.searchController,
                                      hintText:
                                          widget.searchHintText ?? "Search")),
                              ...widget.items.map((item) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      widget.onChanged(item);
                                      _toggleDropdown();
                                    },
                                    child: Container(
                                      padding: widget.itemPadding ??
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 21,
                                          ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: DefaultTextStyle(
                                          style: theme
                                              .dropdownMenuTheme.textStyle!,
                                          child: widget.itemBuilder(item),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasValue = widget.selectedItem != null;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: widget.cornerRadius,
            border: focusNode.hasFocus
                ? GradientBoxBorder(
                    context: context,
                    width: 1,
                  )
                : Border.fromBorderSide(
                    Theme.of(context).inputDecorationTheme.outlineBorder ??
                        const BorderSide()),
            color: widget.buttonBg ??
                (hasValue
                    ? (isDarkMode ? grey5 : grey1)
                    : (isDarkMode ? offBlack : offWhite)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: widget.selectedItem != null
                    ? widget.selectedItemBuilder != null
                        ? widget.selectedItemBuilder!(widget.selectedItem as T)
                        : widget.itemBuilder(widget.selectedItem as T)
                    : Text(
                        widget.hintText,
                        style: widget.buttonTextStyle ??
                            Theme.of(context).textTheme.bodySmall,
                      ),
              ),
              _isOpen
                  ? AppIcons.caretUpIcon(
                      context: context,
                      width: 18,
                      height: 18,
                    )
                  : AppIcons.caretDownIcon(
                      context: context,
                      width: 18,
                      height: 18,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
