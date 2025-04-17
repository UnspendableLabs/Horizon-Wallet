import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';

class FeeConfirmation extends StatefulWidget {
  final String? fee;
  final int? virtualSize;
  final int? adjustedVirtualSize;
  final bool loading;

  const FeeConfirmation({
    super.key,
    this.fee,
    this.virtualSize,
    this.adjustedVirtualSize,
    this.loading = false,
  });

  @override
  State<FeeConfirmation> createState() => _FeeConfirmationState();
}

class _FeeConfirmationState extends State<FeeConfirmation> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Widget _buildLabelValueRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SelectableText(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(width: 12),
          SelectableText(
            widget.loading ? '' : (value ?? ''),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fee Details',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontSize: 14),
                ),
                _isExpanded
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
        if (_isExpanded) ...[
          _buildLabelValueRow('Fee', widget.fee),
          _buildLabelValueRow('Virtual Size', widget.virtualSize?.toString()),
          _buildLabelValueRow(
              'Adjusted Virtual Size', widget.adjustedVirtualSize?.toString()),
        ],
      ],
    );
  }
}
