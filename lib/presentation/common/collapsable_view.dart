import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';

class CollapsableWidget extends StatefulWidget {
  final String title;
  final Widget child;
  const CollapsableWidget(
      {super.key, required this.title, required this.child});

  @override
  State<CollapsableWidget> createState() => _CollapsableWidgetState();
}

class _CollapsableWidgetState extends State<CollapsableWidget> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.labelSmall),),
              _isExpanded
                  ? AppIcons.caretUpIcon(context: context, width: 20, height: 20)
                  : AppIcons.caretDownIcon(context: context, width: 20, height: 20)
            ],
          ),
          ),
        ),
        if (_isExpanded) widget.child,
      ],
    );
  }
}
