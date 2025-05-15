import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/utils/app_icons.dart';

Widget commonHeightSizedBox = const SizedBox(height: 10);
const double defaultButtonHeight = 54;

enum ButtonVariant { black, green, gradient, red, purple }

class GradientContainer extends StatelessWidget {
  final bool isHovered;
  final Widget child;
  final BoxDecoration? decoration;
  const GradientContainer({
    super.key,
    required this.child,
    this.isHovered = false,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = isHovered
        ? brightness == Brightness.dark
            ? const [
                Color.fromRGBO(223, 217, 191, 0.50),
                Color.fromRGBO(238, 208, 154, 0.50),
                Color.fromRGBO(238, 179, 149, 0.50),
                Color.fromRGBO(210, 166, 176, 0.50),
              ]
            : const [
                Color(0xFF563A8E),
                Color(0xFF306E94),
              ]
        : brightness == Brightness.dark
            ? const [
                goldenGradient1,
                yellow1,
                goldenGradient2,
                goldenGradient3,
              ]
            : const [
                duskGradient2,
                duskGradient1,
              ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
        ),
        borderRadius: decoration?.borderRadius,
        border: decoration?.border,
        boxShadow: decoration?.boxShadow,
        color: decoration?.color,
        image: decoration?.image,
        shape: decoration?.shape ?? BoxShape.rectangle,
      ),
      child: child,
    );
  }
}

sealed class ButtonContent {}

class TextButtonContent extends ButtonContent {
  String value;
  TextStyle? style;
  TextButtonContent({required this.value, this.style});
}

class WidgetButtonContent extends ButtonContent {
  Widget value;
  WidgetButtonContent({required this.value});
}

class HorizonButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? width;
  final double? height;
  final bool disabled;
  final ButtonContent child;
  final Widget? icon;
  final double? borderRadius;

  const HorizonButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.height = defaultButtonHeight,
    this.variant = ButtonVariant.green,
    this.disabled = false,
    this.icon,
    this.borderRadius = 50,
  });

  @override
  State<HorizonButton> createState() => _HorizonButtonState();
}

class _HorizonButtonState extends State<HorizonButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: green2,
      foregroundColor: offBlack,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 50),
      ),
    );

    TextStyle textStyle = TextStyle(
        color: style.foregroundColor?.resolve({}),
        fontSize: 16,
        fontWeight: FontWeight.w500);

    BoxBorder? border;

    BoxShadow boxShadow = const BoxShadow(
      color: Color.fromRGBO(255, 255, 255, 0.2),
      blurRadius: 10,
      offset: Offset(0, 0),
    );

    switch (widget.variant) {
      case ButtonVariant.red:
        style = style.copyWith(
          backgroundColor: WidgetStateProperty.all(red1),
          foregroundColor: WidgetStateProperty.all(offBlack),
        );
        textStyle = textStyle.copyWith(
          color: offBlack,
        );
      case ButtonVariant.black:
        style = style.copyWith(
          backgroundColor: WidgetStateProperty.all(black),
          foregroundColor: WidgetStateProperty.all(offWhite),
        );
        textStyle = textStyle.copyWith(
          color: offWhite,
        );
        border = Border.all(color: transparentWhite8, width: 1);
        boxShadow = const BoxShadow(
          color: Color.fromRGBO(255, 255, 255, 0.1),
          blurRadius: 10,
          offset: Offset(0, 0),
        );
      case ButtonVariant.green:
        style = style.copyWith(
          backgroundColor: WidgetStateProperty.all(green2),
          foregroundColor: WidgetStateProperty.all(offBlack),
        );
        style = style.copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)) {
                return const Color.fromARGB(255, 23, 183, 156);
              }
              return null;
            },
          ),
        );
      case ButtonVariant.purple:
        style = style.copyWith(
          backgroundColor: WidgetStateProperty.all(transparentPurple8),
          foregroundColor: WidgetStateProperty.all(offWhite),
        );
        textStyle = textStyle.copyWith(
          color: offWhite,
        );
        boxShadow = const BoxShadow(
          color: Color.fromRGBO(255, 255, 255, 0.1),
          blurRadius: 10,
          offset: Offset(0, 0),
        );
      case ButtonVariant.gradient:
        style = style.copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(offBlack),
        );
    }

    if (widget.disabled) {
      style = style.copyWith(
        backgroundColor: WidgetStateProperty.all(
          const Color.fromRGBO(254, 251, 249, 0.16),
        ),
      );

      textStyle = textStyle.copyWith(
        color: const Color.fromRGBO(254, 251, 249, 0.16),
      );
    }

    if (widget.child is TextButtonContent &&
        (widget.child as TextButtonContent).style != null) {
      textStyle = textStyle.copyWith(
        color: (widget.child as TextButtonContent).style?.color,
        fontSize: (widget.child as TextButtonContent).style?.fontSize,
        fontWeight: (widget.child as TextButtonContent).style?.fontWeight,
      );
    }

    if (widget.variant == ButtonVariant.gradient) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: GradientContainer(
          isHovered: isHovered,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 50),
            boxShadow: isHovered
                ? [
                    boxShadow,
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: widget.disabled ? null : widget.onPressed,
            onHover: (value) => setState(() => isHovered = value),
            style: style.copyWith(
              minimumSize: WidgetStateProperty.all(
                  Size.fromHeight(widget.height ?? defaultButtonHeight)),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 4),
                ],
                // widget.child ?? Text(widget.buttonText, style: textStyle)
                if (widget.child is TextButtonContent)
                  Text((widget.child as TextButtonContent).value,
                      style: textStyle)
                else if (widget.child is WidgetButtonContent)
                  (widget.child as WidgetButtonContent).value
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 50),
          boxShadow: isHovered ? [boxShadow] : null,
        ),
        child: ElevatedButton(
          onPressed: widget.disabled ? null : widget.onPressed,
          onHover: (value) => setState(() => isHovered = value),
          style: style,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 4),
              ],
              if (widget.child is TextButtonContent)
                Text((widget.child as TextButtonContent).value,
                    style: textStyle)
              else if (widget.child is WidgetButtonContent)
                (widget.child as WidgetButtonContent).value
            ],
          ),
        ),
      ),
    );
  }
}

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
                  ? brightness == Brightness.dark
                      ? const [
                          Color.fromRGBO(223, 217, 191, 0.50),
                          Color.fromRGBO(238, 208, 154, 0.50),
                          Color.fromRGBO(238, 179, 149, 0.50),
                          Color.fromRGBO(210, 166, 176, 0.50),
                        ]
                      : const [
                          Color(0xFF563A8E),
                          Color(0xFF306E94),
                        ]
                  : brightness == Brightness.dark
                      ? const [
                          goldenGradient1,
                          yellow1,
                          goldenGradient2,
                          goldenGradient3,
                        ]
                      : const [
                          duskGradient2,
                          duskGradient1,
                        ],
              stops: brightness == Brightness.dark
                  ? const [0.0, 0.325, 0.65, 1.0]
                  : const [0.0, 1.0],
              transform: null,
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
                  brightness == Brightness.dark ? offBlack : offWhite),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                )),
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
  void didUpdateWidget(HorizonOutlinedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onPressed != widget.onPressed && widget.onPressed == null) {
      setState(() {
        isHovered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const isExtension =
        String.fromEnvironment('HORIZON_IS_EXTENSION') == 'true';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: widget.onPressed != null
          ? (_) => mounted ? setState(() => isHovered = true) : null
          : null,
      onExit: widget.onPressed != null
          ? (_) => mounted ? setState(() => isHovered = false) : null
          : null,
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: (isHovered && widget.onPressed != null)
              ? [
                  if (widget.isTransparent == true)
                    BoxShadow(
                      color: isDarkMode
                          ? const Color.fromRGBO(255, 255, 255, 0.10)
                          : const Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 10,
                    )
                  else
                    BoxShadow(
                      color: isDarkMode
                          ? const Color.fromRGBO(255, 255, 255, 0.20)
                          : const Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 10,
                    )
                ]
              : null,
        ),
        child: FilledButton(
          style: widget.isTransparent == true
              ? Theme.of(context).filledButtonTheme.style
              : FilledButton.styleFrom(
                  backgroundColor: isHovered ? green2Hover : green2,
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
    );
  }
}

class GradientBoxBorder extends BoxBorder {
  final BuildContext context;
  const GradientBoxBorder({
    required this.context,
    this.width = 1.0,
  });

  final double width;

  @override
  BorderSide get top => BorderSide.none;

  @override
  BorderSide get bottom => BorderSide.none;

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

    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    final Gradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDarkMode
          ? const [pinkRed, softPinkRed, hyacinth, transparentIvory]
          : const [
              lightYellow,
              greenCyan,
              brightBlue,
              moderateViolet,
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
      context: context,
      width: width * t,
    );
  }
}

class HorizonRedesignDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? selectedValue;
  final String hintText;
  final Widget Function(T)? selectedItemBuilder;
  final bool useModal;
  final bool gradBorder;
  final BorderRadius? cornerRadius;
  final Color? buttonBg;
  final TextStyle? buttonTextStyle;
  final EdgeInsetsGeometry? itemPadding;

  const HorizonRedesignDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.selectedValue,
    required this.hintText,
    this.selectedItemBuilder,
    this.useModal = true,
    this.gradBorder = true,
    this.cornerRadius = const BorderRadius.all(Radius.circular(18)),
    this.buttonBg,
    this.buttonTextStyle,
    this.itemPadding,
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
        _overlayEntry = widget.useModal
            ? _createBlurredOverlayEntry()
            : _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  OverlayEntry _createBlurredOverlayEntry() {
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
                            children: widget.items.map((item) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.onChanged(item.value);
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
                                        style:
                                            theme.dropdownMenuTheme.textStyle!,
                                        child: item.child,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
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
                border: GradientBoxBorder(
                  context: context,
                  width: 1,
                ),
                color: isDarkMode ? grey5 : grey1,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map((item) {
                  TextStyle textStyle = theme.dropdownMenuTheme.textStyle!;
                  if (item.child is Text) {
                    final Text text = item.child as Text;
                    textStyle = textStyle.copyWith(
                      color: text.style?.color,
                      fontSize: text.style?.fontSize,
                      fontWeight: text.style?.fontWeight,
                      fontStyle: text.style?.fontStyle,
                      letterSpacing: text.style?.letterSpacing,
                      wordSpacing: text.style?.wordSpacing,
                      height: text.style?.height,
                      decoration: text.style?.decoration,
                    );
                  }
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
                                style: textStyle,
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
    return widget.useModal
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: Container(
                height: 56,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: widget.cornerRadius,
                  border: focusNode.hasFocus
                      ? GradientBoxBorder(
                          context: context,
                          width: 1,
                        )
                      : Border.fromBorderSide(Theme.of(context)
                              .inputDecorationTheme
                              .outlineBorder ??
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
                      child: widget.selectedValue != null
                          ? widget.selectedItemBuilder != null
                              ? widget.selectedItemBuilder!(
                                  widget.selectedValue as T)
                              : Text(
                                  (widget.items
                                          .firstWhere((item) =>
                                              item.value ==
                                              widget.selectedValue)
                                          .child as Text)
                                      .data!,
                                  style: widget.buttonTextStyle ??
                                      Theme.of(context).textTheme.bodySmall,
                                )
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
          )
        : CompositedTransformTarget(
            link: _layerLink,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  height: 56,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: focusNode.hasFocus
                        ? GradientBoxBorder(
                            context: context,
                            width: 1,
                          )
                        : Border.fromBorderSide(Theme.of(context)
                                .inputDecorationTheme
                                .outlineBorder ??
                            const BorderSide()),
                    color: hasValue
                        ? (isDarkMode ? grey5 : grey1)
                        : (isDarkMode ? offBlack : offWhite),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: widget.selectedValue != null
                            ? widget.selectedItemBuilder != null
                                ? widget.selectedItemBuilder!(
                                    widget.selectedValue as T)
                                : Text(
                                    (widget.items
                                            .firstWhere((item) =>
                                                item.value ==
                                                widget.selectedValue)
                                            .child as Text)
                                        .data!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  )
                            : Text(
                                widget.hintText,
                                style: Theme.of(context).textTheme.bodySmall,
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
            ),
          );
  }
}

class BlurredBackgroundDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? selectedValue;
  final String hintText;

  const BlurredBackgroundDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.selectedValue,
    required this.hintText,
  });

  @override
  State<BlurredBackgroundDropdown<T>> createState() =>
      _BlurredBackgroundDropdownState<T>();
}

class _BlurredBackgroundDropdownState<T>
    extends State<BlurredBackgroundDropdown<T>> {
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: transparentBlack33,
                ),
              ),
            ),
          ),
          // Centered dropdown content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200,
                maxWidth: 200,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: GradientBoxBorder(
                    context: context,
                    width: 1,
                  ),
                  color: isDarkMode ? grey5 : grey1,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              item.child,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasValue = widget.selectedValue != null;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: focusNode.hasFocus
                ? GradientBoxBorder(
                    context: context,
                    width: 1,
                  )
                : Border.fromBorderSide(
                    Theme.of(context).inputDecorationTheme.outlineBorder ??
                        const BorderSide()),
            color: hasValue
                ? (isDarkMode ? grey5 : grey1)
                : (isDarkMode ? offBlack : offWhite),
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

enum HorizonToggleType { success, warning, error }

class HorizonToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final HorizonToggleType? type;
  final Color? gutterInactiveColor;
  final Color? gutterActiveColor;
  final Color? thumbInactiveColor;
  final Color? thumbActiveColor;
  final Widget? thumbInactiveIcon;
  final Widget? thumbActiveIcon;

  const HorizonToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.type = HorizonToggleType.success,
    this.gutterInactiveColor,
    this.gutterActiveColor,
    this.thumbInactiveColor,
    this.thumbActiveColor,
    this.thumbInactiveIcon,
    this.thumbActiveIcon,
  });


  @override
  State<HorizonToggle> createState() => _HorizonToggleState();
}

class _HorizonToggleState extends State<HorizonToggle> {
  late Color _gutterActiveColor = green2;
  late Color _gutterInactiveColor = transparentWhite8;
  late Color _thumbActiveColor = offWhite;
  late Color _thumbInactiveColor = offWhite;
  late Widget _thumbActiveIcon;

  void _initializeColors() {
    switch (widget.type) {
      case HorizonToggleType.success:
        _gutterActiveColor = green2;
        _gutterInactiveColor = transparentWhite8;
        _thumbActiveColor = offWhite;
        _thumbInactiveColor = offWhite;
        _thumbActiveIcon = const Icon(Icons.check, color: green3, size: 14);
        break;
      case HorizonToggleType.warning:
        _gutterActiveColor = yellow1;
        _gutterInactiveColor = transparentWhite8;
        _thumbActiveColor = gray5;
        _thumbInactiveColor = offWhite;
        _thumbActiveIcon = const Icon(Icons.check, color: yellow1, size: 14);
        break;
      case HorizonToggleType.error:
        _gutterActiveColor = red1;
        _gutterInactiveColor = transparentWhite8;
        _thumbActiveColor = offWhite;
        _thumbInactiveColor = offWhite;
        _thumbActiveIcon = const Icon(Icons.check, color: red1, size: 14);
        break;
      default:
        _gutterActiveColor = widget.gutterActiveColor ?? green2;
        _gutterInactiveColor = widget.gutterInactiveColor ?? transparentWhite8;
        _thumbActiveColor = widget.thumbActiveColor ?? offWhite;
        _thumbInactiveColor = widget.thumbInactiveColor ?? offWhite;
        _thumbActiveIcon = widget.thumbActiveIcon ??
            const Icon(Icons.check, color: green3, size: 14);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeColors();
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: Container(
          width: 60,
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70),
            border: Border.fromBorderSide(
                Theme.of(context).inputDecorationTheme.outlineBorder ??
                    const BorderSide()),
            color: widget.value ? _gutterActiveColor : _gutterInactiveColor,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment:
                widget.value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.value ? _thumbActiveColor : _thumbInactiveColor,
              ),
              child: widget.value
                  ? widget.thumbActiveIcon ?? _thumbActiveIcon
                  : widget.thumbInactiveIcon,
            ),
          ),
        ),
      ),
    );
  }
}

class HorizonTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final dynamic Function(dynamic)? onSubmitted;
  final dynamic Function(dynamic)? onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const HorizonTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  State<HorizonTextField> createState() => _HorizonTextFieldState();
}

class _HorizonTextFieldState extends State<HorizonTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(HorizonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        _hasText != widget.controller.text.isNotEmpty) {
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>()!;

    return FormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> field) {
        final hasError = field.hasError;

        // Update field value when controller changes
        widget.controller.addListener(() {
          field.didChange(widget.controller.text);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: _hasText
                      ? customTheme.inputBackground
                      : customTheme.inputBackgroundEmpty,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: hasError
                        ? Border.all(color: customTheme.errorColor, width: 1)
                        : _focusNode.hasFocus
                            ? GradientBoxBorder(
                                context: context,
                                width: 1,
                              )
                            : Border.all(color: customTheme.inputBorderColor),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          enabled: widget.enabled,
                          controller: widget.controller,
                          focusNode: _focusNode,
                          obscureText: widget.obscureText,
                          onChanged: (value) {
                            if (widget.onChanged != null) {
                              widget.onChanged!(value);
                            }
                            field.didChange(value);
                          },
                          inputFormatters: widget.inputFormatters,
                          onFieldSubmitted: widget.onSubmitted,
                          onTap: () {
                            FocusScope.of(context).requestFocus(_focusNode);
                          },
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: customTheme.inputTextColor,
                          ),
                          decoration: InputDecoration(
                            fillColor: _hasText
                                ? customTheme.inputBackground
                                : customTheme.inputBackgroundEmpty,
                            labelText: widget.label,
                            labelStyle: theme.textTheme.bodySmall,
                            isDense: theme.inputDecorationTheme.isDense,
                            contentPadding:
                                theme.inputDecorationTheme.contentPadding,
                            border: theme.inputDecorationTheme.border,
                            hintText: widget.hintText,
                            hintStyle: theme.inputDecorationTheme.hintStyle,
                            errorStyle: const TextStyle(
                              height: 0,
                              fontSize: 0,
                              color: Colors.transparent,
                            ),
                          ),
                          showCursor: true,
                        ),
                      ),
                      if (widget.suffixIcon != null) ...[
                        widget.suffixIcon!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (hasError) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 16, top: 4, bottom: 0),
                child: Text(
                  textAlign: TextAlign.center,
                  field.errorText ?? widget.errorText ?? '',
                  style: TextStyle(
                    color: customTheme.errorColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class HorizonPasswordPrompt extends StatefulWidget {
  final Function(String) onPasswordSubmitted;
  final VoidCallback onCancel;
  final String buttonText;
  final String title;
  final String? errorText;
  final bool isLoading;

  const HorizonPasswordPrompt({
    super.key,
    required this.onPasswordSubmitted,
    required this.onCancel,
    this.buttonText = 'Continue',
    this.title = 'Enter Password',
    this.errorText,
    this.isLoading = false,
  });

  @override
  State<HorizonPasswordPrompt> createState() => _HorizonPasswordPromptState();
}

class _HorizonPasswordPromptState extends State<HorizonPasswordPrompt> {
  final TextEditingController _controller = TextEditingController();
  bool _obscurePassword = true;

  void _handleSubmit() async {
    if (widget.isLoading) return;
    await widget.onPasswordSubmitted(_controller.text);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onCancel,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: transparentBlack33,
                ),
              ),
            ),
          ),
          // Centered dialog content
          Center(
            child: Container(
              width: 335,
              height: 234,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: GradientBoxBorder(
                  context: context,
                  width: 1,
                ),
                color: isDarkMode ? grey5 : grey1,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  HorizonTextField(
                    controller: _controller,
                    hintText: 'Password',
                    errorText: widget.errorText,
                    obscureText: _obscurePassword,
                    suffixIcon: AppIcons.iconButton(
                      context: context,
                      icon: _obscurePassword
                          ? AppIcons.eyeClosedIcon(
                              context: context,
                              width: 24,
                              height: 24,
                            )
                          : AppIcons.eyeOpenIcon(
                              context: context,
                              width: 24,
                              height: 24,
                            ),
                      onPressed: _togglePasswordVisibility,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: HorizonOutlinedButton(
                      onPressed: widget.isLoading ? null : _handleSubmit,
                      buttonText: widget.buttonText,
                      isTransparent: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HorizonActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;
  final bool isTransparent;

  const HorizonActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isTransparent = false,
  });

  @override
  State<HorizonActionButton> createState() => _HorizonActionButtonState();
}

class _HorizonActionButtonState extends State<HorizonActionButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.onPressed != null
          ? (_) => setState(() => isHovered = true)
          : null,
      onExit: widget.onPressed != null
          ? (_) => setState(() => isHovered = false)
          : null,
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 44,
        ),
        child: OutlinedButton(
          onPressed: widget.onPressed,
          style: widget.isTransparent
              ? Theme.of(context).outlinedButtonTheme.style
              : Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    side: WidgetStateProperty.all(
                      const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                        isHovered ? green2Hover : green2),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    ),
                  ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.icon,
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: widget.isTransparent
                      ? Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          )
                      : Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: offBlack,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
