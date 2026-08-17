import 'package:flutter/material.dart';
import 'package:salonverse/models/notification_model.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/empty_state.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final result = await AppService.instance.getNotifications();
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
    await AppService.instance.markNotificationAsRead(id);
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
        await AppService.instance.markNotificationAsRead(n.id);
      }
    }
    if (mounted) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
      });
      AppFeedback.success(context, "All notifications marked as read.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text(
                "Read All",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchNotifications,
                child: _notifications.isEmpty
                    ? EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: "No notifications",
                        subtitle:
                            "You're all caught up! Important booking updates will appear here.",
                        actionLabel: "Refresh",
                        onAction: _fetchNotifications,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          return _buildNotificationCard(theme, isDark, item);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildNotificationCard(
    ThemeData theme,
    bool isDark,
    NotificationModel item,
  ) {
    final IconData iconData;
    final Color iconColor;

    switch (item.type.toLowerCase()) {
      case 'booking':
        iconData = Icons.calendar_today_rounded;
        iconColor = const Color(0xFFEC4899);
        break;
      case 'payment':
        iconData = Icons.payment_rounded;
        iconColor = Colors.green;
        break;
      case 'promo':
      case 'offer':
        iconData = Icons.local_offer_outlined;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications_outlined;
        iconColor = theme.colorScheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead
            ? (isDark ? const Color(0xFF161514) : Colors.white)
            : (isDark ? const Color(0xFF241C1E) : const Color(0xFFFFF1F4)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isRead
              ? (isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200)
              : const Color(0xFFEC4899).withAlpha(80),
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () {
            if (!item.isRead) {
              _markAsRead(item.id);
            }
          },
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withAlpha(20),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.message,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTimeAgo(item.createdAt),
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
