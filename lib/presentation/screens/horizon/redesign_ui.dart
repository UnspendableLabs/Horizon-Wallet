import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class HorizonGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isDarkMode;

  const HorizonGradientButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isDarkMode
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
            stops:
                isDarkMode ? const [0.0, 0.325, 0.65, 1.0] : const [0.0, 1.0],
            transform:
                isDarkMode ? null : const GradientRotation(139.18 * pi / 180),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.all(20),
          ),
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class HorizonOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isDarkMode;
  final bool? isTransparent;

  const HorizonOutlinedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.isDarkMode,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isTransparent == true
              ? (isDarkMode ? importButtonDarkBackground : Colors.white)
              : tealButtonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide.none,
          ),
          padding: const EdgeInsets.all(20),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            color: isTransparent == true
                ? (isDarkMode ? Colors.white : Colors.black)
                : const Color.fromRGBO(9, 9, 9, 1),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
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
  final bool isDarkMode;

  const HorizonRedesignDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.selectedValue,
    required this.hintText,
    required this.isDarkMode,
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

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 10.0), // 10px spacing
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: const GradientBoxBorder(width: 1),
              color: widget.isDarkMode
                  ? darkThemeBackgroundColor
                  : lightThemeBackgroundColor,
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
                          horizontal: 12, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: item.child,
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: widget.isDarkMode
                        ? inputDarkBorderColor
                        : inputLightBorderColor),
            color: hasValue
                ? (widget.isDarkMode
                    ? inputDarkBackground
                    : inputLightBackground)
                : (widget.isDarkMode
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
                  style: TextStyle(
                    fontSize: 12,
                    color: hasValue
                        ? (widget.isDarkMode ? Colors.white : Colors.black)
                        : (widget.isDarkMode
                            ? inputDarkLabelColor
                            : inputLightLabelColor),
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: widget.isDarkMode ? Colors.white : Colors.black,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
