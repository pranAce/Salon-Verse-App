import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/controllers/settings_provider.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out from SalonVerse?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                AppFeedback.success(context, "Logged out successfully.");
                context.go('/auth/login');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final settings = context.watch<SettingsProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final isSalonRole = user?.isSalonRole ?? false;
    final upcomingCount = bookingProvider.bookings
        .where(
          (b) =>
              b.status != 'completed' &&
              b.status != 'cancelled' &&
              b.status != 'no_show',
        )
        .length;
    final completedCount = bookingProvider.bookings
        .where((b) => b.status.toLowerCase() == 'completed')
        .length;
    final favoritesCount = user?.favoriteSalons.length ?? 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark
                  ? const Color(0xFF4C0E1E)
                  : const Color(
                      0xFFFFBCC3,
                    ),
              isDark ? const Color(0xFF090808) : Colors.white,
            ],
            begin: Alignment.topCenter,
            end: const Alignment(0, 0.1),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: theme.colorScheme.primary.withAlpha(
                            20,
                          ),
                          backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF090808)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hi, ${user?.name ?? "User"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Glow looks good on you ✨',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1C1B)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 0 : 5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                color: isDark ? Colors.white : Colors.black87,
                                size: 20,
                              ),
                              Positioned(
                                top: 11,
                                right: 11,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEC4899),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => context.push('/profile/account'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1C1B)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 0 : 5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    theme,
                    Icons.calendar_today_rounded,
                    const Color(0xFFEC4899),
                    upcomingCount.toString(),
                    "Upcoming\nBookings",
                  ),
                  _buildDivider(theme),
                  _buildStatItem(
                    theme,
                    Icons.check_circle_rounded,
                    Colors.green.shade600,
                    completedCount.toString(),
                    "Completed\nBookings",
                  ),
                  _buildDivider(theme),
                  GestureDetector(
                    onTap: () => context.push('/profile/favorites'),
                    child: _buildStatItem(
                      theme,
                      Icons.favorite_rounded,
                      const Color(0xFFEC4899),
                      favoritesCount.toString(),
                      "Saved\nSalons",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF1E70),
                      Color(0xFFFF7643),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1E70).withAlpha(45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "salonVerse Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "You're enjoying exclusive benefits",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/loyalty'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "Loyalty Hub",
                              style: TextStyle(
                                color: Color(0xFFEC4899),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFEC4899),
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 28),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Tools",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildToolItem(
                        theme,
                        isDark,
                        Icons.credit_card_rounded,
                        const Color(0xFFFF1E70),
                        "My Payments",
                        () => context.push('/profile/payments'),
                      ),
                      _buildToolItem(
                        theme,
                        isDark,
                        Icons.local_offer_outlined,
                        Colors.orange,
                        "Offers",
                        () => context.push('/profile/offers'),
                      ),
                      _buildToolItem(
                        theme,
                        isDark,
                        Icons.location_on_outlined,
                        const Color(0xFFEC4899),
                        "My Addresses",
                        () => context.push('/profile/addresses'),
                      ),
                      _buildToolItem(
                        theme,
                        isDark,
                        Icons.chat_bubble_outline_rounded,
                        Colors.blue,
                        "Help & Support",
                        () => context.push('/support'),
                      ),
                      _buildToolItem(
                        theme,
                        isDark,
                        Icons.card_giftcard_rounded,
                        Colors.green,
                        "Refer & Earn",
                        () => context.push('/profile/refer'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSalonRole) ...[
                    Text(
                      "Workspace Settings",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 0 : 8),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildGroupedMenuTile(
                            theme,
                            Icons.room_service_outlined,
                            const Color(0xFFEC4899),
                            "Manage Salon Services",
                            () => context.push('/salon-workspace/services'),
                            showDivider: true,
                          ),
                          _buildGroupedMenuTile(
                            theme,
                            Icons.people_outline_rounded,
                            const Color(0xFFEC4899),
                            "Manage Stylist Roster",
                            () => context.push('/salon-workspace/staff'),
                            showDivider: true,
                          ),
                          _buildGroupedMenuTile(
                            theme,
                            Icons.storefront_rounded,
                            const Color(0xFFEC4899),
                            "Edit Salon Profile Details",
                            () => context.push('/salon-workspace/settings'),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 0 : 8),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildGroupedMenuTile(
                          theme,
                          Icons.person_outline_rounded,
                          const Color(0xFFEC4899),
                          "Personal Information",
                          () => context.push('/profile/account'),
                          showDivider: true,
                        ),
                        _buildGroupedMenuTile(
                          theme,
                          Icons.notifications_none_rounded,
                          const Color(0xFFEC4899),
                          "Notifications",
                          () => context.push('/notifications'),
                          showDivider: true,
                        ),
                        _buildGroupedMenuTile(
                          theme,
                          Icons.shield_outlined,
                          const Color(0xFFEC4899),
                          "Privacy & Security",
                          () {},
                          showDivider: true,
                        ),

                        _buildGroupedMenuTile(
                          theme,
                          Icons.language_rounded,
                          const Color(0xFFEC4899),
                          "Language",
                          () {},
                          showDivider: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "English",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        SwitchListTile(
                          value: settings.isDarkMode,
                          activeThumbColor: theme.colorScheme.primary,
                          title: const Text(
                            "Dark Mode",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          secondary: const Icon(
                            Icons.dark_mode_outlined,
                            color: Color(0xFFE91E63),
                          ),
                          onChanged: (val) => settings.setDarkMode(val),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color: theme.colorScheme.outline.withAlpha(
                              isDark ? 15 : 30,
                            ),
                          ),
                        ),

                        _buildGroupedMenuTile(
                          theme,
                          Icons.logout_rounded,
                          const Color(0xFFE91E63),
                          "Log Out",
                          () => _showLogoutDialog(context),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 32,
      color: theme.colorScheme.outline.withAlpha(40),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    Color iconColor,
    String count,
    String label,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolItem(
    ThemeData theme,
    bool isDark,
    IconData icon,
    Color iconColor,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 0 : 4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedMenuTile(
    ThemeData theme,
    IconData icon,
    Color iconColor,
    String label,
    VoidCallback onTap, {
    required bool showDivider,
    Widget? trailing,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: iconColor, size: 22),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            trailing:
                trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                  size: 20,
                ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outline.withAlpha(isDark ? 15 : 30),
            ),
          ),
      ],
    );
  }
}
