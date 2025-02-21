import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class HorizonGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String buttonText;

  const HorizonGradientButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  State<HorizonGradientButton> createState() => _HorizonGradientButtonState();
}

class _HorizonGradientButtonState extends State<HorizonGradientButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isHovered
                  ? const [
                      Color.fromRGBO(223, 217, 191, 0.50),
                      Color.fromRGBO(238, 208, 154, 0.50),
                      Color.fromRGBO(238, 179, 149, 0.50),
                      Color.fromRGBO(210, 166, 176, 0.50),
                    ]
                  : brightness == Brightness.dark
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
              stops: brightness == Brightness.dark && !isHovered
                  ? const [0.0, 0.325, 0.65, 1.0]
                  : isHovered
                      ? const [0.0, 0.325, 0.65, 1.0]
                      : const [0.0, 1.0],
              transform: brightness == Brightness.dark || isHovered
                  ? null
                  : const GradientRotation(139.18 * pi / 180),
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: isHovered
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(255, 255, 255, 0.20),
                      blurRadius: 10,
                    )
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ButtonStyle(
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).textTheme.labelLarge?.color),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(62)),
            ),
            child: Text(widget.buttonText,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

class HorizonOutlinedButton extends StatefulWidget {
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
  State<HorizonOutlinedButton> createState() => _HorizonOutlinedButtonState();
}

class _HorizonOutlinedButtonState extends State<HorizonOutlinedButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    const isExtension =
        String.fromEnvironment('HORIZON_IS_EXTENSION') == 'true';

    return MouseRegion(
      onEnter: widget.isTransparent == true
          ? (_) => setState(() => isHovered = true)
          : null,
      onExit: widget.isTransparent == true
          ? (_) => setState(() => isHovered = false)
          : null,
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: Container(
          decoration: widget.isTransparent == true && isHovered
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(255, 255, 255, 0.10),
                      blurRadius: 10,
                    )
                  ],
                )
              : null,
          child: FilledButton(
            style: widget.isTransparent == true ||
                    (widget.isTransparent == true && isHovered)
                ? Theme.of(context).filledButtonTheme.style
                : FilledButton.styleFrom(
                    backgroundColor: tealButtonColor,
                    foregroundColor: Colors.black,
                  ),
            onPressed: widget.onPressed,
            child: Text(
              widget.buttonText,
              style: TextStyle(
                fontWeight: widget.isTransparent == true || isExtension
                    ? FontWeight.normal
                    : FontWeight.w600,
                color: widget.isTransparent == true
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : null,
              ),
            ),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
                                .firstWhere((item) =>
                                    item.value == widget.selectedValue)
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
      ),
    );
  }
}
