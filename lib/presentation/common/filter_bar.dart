import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class FilterBar extends StatelessWidget {
  final Object currentFilter;
  final Function(Object) onFilterSelected;
  final VoidCallback onClearFilter;
  final List<FilterOption> filterOptions;
  final double? paddingHorizontal;
  final bool allowDeselect;

  const FilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
    required this.onClearFilter,
    required this.filterOptions,
    this.paddingHorizontal,
    this.allowDeselect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal ?? 16),
      child: Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    transparentBlack8,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: filterOptions.map((option) {
            final isSelected = currentFilter == option.value;
            return FilterButton(
              label: option.label,
              isSelected: isSelected,
              onTap: () {
                if (isSelected && allowDeselect) {
                  onClearFilter();
                } else {
                  onFilterSelected(option.value);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? transparentPurple16 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final Object value;

  const FilterOption({required this.label, required this.value});
}
