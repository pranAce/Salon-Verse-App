import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/notifications/models/notification_model.dart';
import 'package:salonverse/features/notifications/services/notification_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final result = await _notificationService.getNotifications();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result is Success<List<NotificationModel>>) {
          _notifications = result.data;
        }
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    await _notificationService.markAsRead(id);
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
      });
    }
  }

  Future<void> _markAllAsRead() async {
    for (var n in _notifications) {
      if (!n.isRead) {
        await _notificationService.markAsRead(n.id);
      }
    }
    if (mounted) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Read All',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchNotifications,
          color: AppColors.primary,
          child: _isLoading
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SVSkeleton(
                      width: double.infinity,
                      height: 76,
                      borderRadius: 16,
                    ),
                  ),
                )
              : _notifications.isEmpty
              ? const SVEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No Notifications',
                  description:
                      'You are all caught up! Booking updates and alerts will appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return _buildNotificationCard(isDark, item);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(bool isDark, NotificationModel item) {
    final IconData iconData;
    final Color iconColor;

    switch (item.type.toLowerCase()) {
      case 'booking':
        iconData = Icons.calendar_today_rounded;
        iconColor = AppColors.primary;
        break;
      case 'payment':
        iconData = Icons.receipt_rounded;
        iconColor = const Color(0xFF10B981);
        break;
      case 'promo':
      case 'offer':
        iconData = Icons.local_offer_outlined;
        iconColor = const Color(0xFFF59E0B);
        break;
      default:
        iconData = Icons.notifications_outlined;
        iconColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () {
        if (!item.isRead) _markAsRead(item.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead
              ? (isDark ? AppColors.darkSurface : Colors.white)
              : (isDark ? const Color(0xFF28141D) : AppColors.primaryTint),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : AppColors.primary.withAlpha(80),
          ),
          boxShadow: isDark ? null : AppSpacing.softShadow(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimeAgo(item.createdAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(dynamic raw) {
    if (raw == null) return 'Recent';
    DateTime dt;
    if (raw is DateTime) {
      dt = raw;
    } else if (raw is String) {
      dt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      return 'Recent';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
