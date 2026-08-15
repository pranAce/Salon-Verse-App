import 'package:flutter/material.dart';

class AppFeedback {
  static void success(BuildContext context, String message) {
    _show(context, message, _FeedbackType.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, _FeedbackType.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, _FeedbackType.info);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, _FeedbackType.warning);
  }

  static void _show(BuildContext context, String message, _FeedbackType type) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case _FeedbackType.success:
        bgColor = isDark ? const Color(0xFF1B3726) : const Color(0xFF2E7D32);
        iconColor = isDark ? const Color(0xFF66BB6A) : Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case _FeedbackType.error:
        bgColor = isDark ? const Color(0xFF3C1A1A) : const Color(0xFFC62828);
        iconColor = isDark ? const Color(0xFFEF5350) : Colors.white;
        icon = Icons.error_rounded;
        break;
      case _FeedbackType.warning:
        bgColor = isDark ? const Color(0xFF3C2F15) : const Color(0xFFE65100);
        iconColor = isDark ? const Color(0xFFFFB74D) : Colors.white;
        icon = Icons.warning_rounded;
        break;
      case _FeedbackType.info:
        bgColor = isDark ? const Color(0xFF1A2A3C) : const Color(0xFF1565C0);
        iconColor = isDark ? const Color(0xFF42A5F5) : Colors.white;
        icon = Icons.info_rounded;
        break;
    }

    final textColor = isDark ? Colors.white.withAlpha(230) : Colors.white;
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(milliseconds: 2500),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}

enum _FeedbackType { success, error, warning, info }
