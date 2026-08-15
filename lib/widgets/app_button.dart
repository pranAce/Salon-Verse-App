import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salonverse/theme/app_theme.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
    );
    _controller.value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapCancel() {
    _controller.forward();
  }

  void _handlePressed() {
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final primaryColor = widget.backgroundColor ?? theme.colorScheme.primary;

    Widget buttonChild;
    if (widget.isOutlined) {
      buttonChild = OutlinedButton(
        onPressed: isEnabled ? _handlePressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          side: BorderSide(
            color: isEnabled
                ? primaryColor.withAlpha(isDark ? 120 : 160)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          foregroundColor: widget.foregroundColor ?? primaryColor,
        ),
        child: _buildChild(theme),
      );
    } else {
      buttonChild = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: primaryColor.withAlpha(isDark ? 30 : 40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: isEnabled ? _handlePressed : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            backgroundColor: primaryColor,
            foregroundColor:
                widget.foregroundColor ?? theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            elevation: 0,
          ),
          child: _buildChild(theme),
        ),
      );
    }

    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      child: ScaleTransition(scale: _scaleAnimation, child: buttonChild),
    );
  }

  Widget _buildChild(ThemeData theme) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.isOutlined
              ? theme.colorScheme.primary
              : (widget.foregroundColor ?? theme.colorScheme.onPrimary),
        ),
      );
    }

    final textStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.2,
    );

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
          Text(widget.label, style: textStyle),
        ],
      );
    }

    return Text(widget.label, style: textStyle);
  }
}
