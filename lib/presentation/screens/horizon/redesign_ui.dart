import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/utils/app_icons.dart';

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
  const GradientBoxBorder({
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
                                .firstWhere((item) =>
                                    item.value == widget.selectedValue)
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
                  border: const GradientBoxBorder(width: 1),
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
                              DefaultTextStyle(
                                style: theme.dropdownMenuTheme.textStyle!,
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
                ? const GradientBoxBorder(width: 1)
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

class HorizonToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? backgroundColor;

  const HorizonToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.backgroundColor,
  });

  @override
  State<HorizonToggle> createState() => _HorizonToggleState();
}

class _HorizonToggleState extends State<HorizonToggle> {
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
              color: widget.value
                  ? (widget.backgroundColor ?? green2)
                  : Theme.of(context)
                      .inputDecorationTheme
                      .outlineBorder
                      ?.color),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment:
                widget.value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: offWhite,
              ),
              child: widget.value
                  ? Icon(
                      Icons.check,
                      color: widget.backgroundColor ?? green2,
                      size: 16,
                    )
                  : null,
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
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
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
                            ? const GradientBoxBorder(width: 1)
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
                          onFieldSubmitted: widget.onSubmitted,
                          onTap: () {
                            FocusScope.of(context).requestFocus(_focusNode);
                          },
                          style: TextStyle(
                            fontSize: 12,
                            color: customTheme.inputTextColor,
                          ),
                          decoration: InputDecoration(
                            labelText: widget.label,
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
            if (hasError || widget.errorText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
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
                border: const GradientBoxBorder(width: 1),
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
                              width: 10,
                              height: 10,
                            )
                          : AppIcons.eyeOpenIcon(
                              context: context,
                              width: 12,
                              height: 12,
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
