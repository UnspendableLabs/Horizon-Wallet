import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class HorizonGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;

  const HorizonGradientButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: brightness == Brightness.dark
                ? const [
                    createButtonDarkGradient1,
                    createButtonDarkGradient2,
                    createButtonDarkGradient3,
                    createButtonDarkGradient4,
                  ]
                : const [
                    createButtonLightGradient1,
                    createButtonLightGradient3,
                  ],
            stops: brightness == Brightness.dark
                ? const [0.0, 0.325, 0.65, 1.0]
                : const [0.0, 1.0],
            transform: brightness == Brightness.dark
                ? null
                : const GradientRotation(139.18 * pi / 180),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class HorizonOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool? isTransparent;

  const HorizonOutlinedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton(
        style: isTransparent == true
            ? Theme.of(context).filledButtonTheme.style
            : FilledButton.styleFrom(
                backgroundColor: tealButtonColor,
                foregroundColor: Colors.black,
              ),
        onPressed: onPressed,
        child: Text(buttonText,
            style: TextStyle(
                fontWeight: isTransparent == true
                    ? FontWeight.normal
                    : FontWeight.w600)),
      ),
    );
  }
}

class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({
    this.width = 1.0,
  });

  final double width;

  @override
  BorderSide get top => BorderSide.none;

  @override
  BorderSide get right => BorderSide.none;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get left => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    const Gradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromRGBO(250, 204, 206, 1),
        Color.fromRGBO(246, 167, 168, 1),
        Color.fromRGBO(163, 167, 211, 1),
        Color.fromRGBO(202, 206, 250, 0.96),
      ],
    );

    if (borderRadius != null) {
      final RRect rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
      final Path path = Path()..addRRect(rrect);
      paint.shader = gradient.createShader(rect);
      canvas.drawPath(path, paint);
    } else {
      paint.shader = gradient.createShader(rect);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(
      width: width * t,
    );
  }
}

class HorizonRedesignDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? selectedValue;
  final String hintText;

  const HorizonRedesignDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.selectedValue,
    required this.hintText,
  });

  @override
  State<HorizonRedesignDropdown<T>> createState() =>
      _HorizonRedesignDropdownState<T>();
}

class _HorizonRedesignDropdownState<T>
    extends State<HorizonRedesignDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    focusNode.dispose();
    super.dispose();
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

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 10.0),
          child: Theme(
            data: theme,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: const GradientBoxBorder(width: 1),
                color: isDarkMode ? inputDarkBackground : inputLightBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map((item) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        widget.onChanged(item.value);
                        _toggleDropdown();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: DefaultTextStyle(
                                style: theme.dropdownMenuTheme.textStyle!,
                                child: item.child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasValue = widget.selectedValue != null;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: focusNode.hasFocus
                ? const GradientBoxBorder(width: 1)
                : Border.all(
                    color: isDarkMode
                        ? inputDarkBorderColor
                        : inputLightBorderColor),
            color: hasValue
                ? (isDarkMode ? inputDarkBackground : inputLightBackground)
                : (isDarkMode
                    ? darkThemeBackgroundColor
                    : lightThemeBackgroundColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.selectedValue != null
                      ? (widget.items
                              .firstWhere(
                                  (item) => item.value == widget.selectedValue)
                              .child as Text)
                          .data!
                      : widget.hintText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
