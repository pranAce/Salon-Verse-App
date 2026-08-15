import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final int? maxLength;
  final int maxLines;
  final TextAlign textAlign;
  final TextStyle? style;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      maxLength: maxLength,
      maxLines: maxLines,
      textAlign: textAlign,
      style:
          style ??
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: label,
        counterText: maxLength != null ? "" : null,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 18,
                color: theme.colorScheme.primary.withAlpha(200),
              )
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
