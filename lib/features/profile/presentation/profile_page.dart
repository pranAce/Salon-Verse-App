import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/features/home/services/settings_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Log Out?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of your SalonVerse account?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              await auth.logout();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
            child: const Text('Log Out'),
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
      context.read<LoyaltyProvider>().loadLoyaltyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final settings = context.watch<SettingsProvider>();
    final bookingProv = context.watch<BookingProvider>();
    final loyalty = context.watch<LoyaltyProvider>();

    final bookingsCount = bookingProv.bookings.length;
    final favoritesCount = user?.favoriteSalons.length ?? 0;
    final loyaltyPoints = loyalty.profile?.loyaltyCredits ?? 0;
    final tier = loyalty.profile?.tier.toUpperCase() ?? 'MEMBER';

    final userName = user?.name ?? 'SalonVerse User';
    final userEmail = user?.email ?? 'user@salonverse.com';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account & Profile',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.primaryTint,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tier,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => context.push('/profile/account'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  boxShadow: isDark ? null : AppSpacing.softShadow(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Appointments',
                      '$bookingsCount',
                      () => context.go('/bookings'),
                      isDark,
                    ),
                    Container(
                      height: 28,
                      width: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    _buildStatItem(
                      'Favorites',
                      '$favoritesCount',
                      () => context.push('/profile/favorites'),
                      isDark,
                    ),
                    Container(
                      height: 28,
                      width: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    _buildStatItem(
                      'Points',
                      '$loyaltyPoints',
                      () => context.push('/loyalty'),
                      isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('ACCOUNT', isDark),
              _buildSettingsGroup([
                _buildTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Name, phone, email & gender',
                  onTap: () => context.push('/profile/account'),
                  isDark: isDark,
                ),
                _buildTile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  subtitle: 'Manage home & workplace delivery points',
                  onTap: () => context.push('/profile/addresses'),
                  isDark: isDark,
                ),
                _buildTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Saved cards & digital wallets',
                  onTap: () => context.push('/profile/payments'),
                  isDark: isDark,
                ),
                _buildTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Saved Salons & Favorites',
                  subtitle: 'Your preferred beauty venues',
                  onTap: () => context.push('/profile/favorites'),
                  isDark: isDark,
                  isLast: true,
                ),
              ], isDark),

              const SizedBox(height: 20),

              _buildSectionTitle('BENEFITS & OFFERS', isDark),
              _buildSettingsGroup([
                _buildTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Loyalty & VIP Pass',
                  subtitle: 'Tier progress, rewards catalog & points',
                  onTap: () => context.push('/loyalty'),
                  isDark: isDark,
                ),
                _buildTile(
                  icon: Icons.local_offer_outlined,
                  title: 'Exclusive Deals & Coupons',
                  subtitle: 'Special salon discounts & promos',
                  onTap: () => context.push('/offers'),
                  isDark: isDark,
                ),
                _buildTile(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Refer a Friend & Earn',
                  subtitle: 'Share code for bonus credits',
                  onTap: () => context.push('/profile/refer'),
                  isDark: isDark,
                  isLast: true,
                ),
              ], isDark),

              const SizedBox(height: 20),

              _buildSectionTitle('PREFERENCES & SUPPORT', isDark),
              _buildSettingsGroup([
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurfaceSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Theme',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              isDark
                                  ? 'Obsidian mode active'
                                  : 'Studio light mode active',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isDark,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          settings.toggleTheme(val);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                _buildTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Appointment alerts & promos',
                  onTap: () => context.push('/notifications'),
                  isDark: isDark,
                ),
                _buildTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Customer Support',
                  subtitle: 'FAQs, ticket inquiries & contact',
                  onTap: () => context.push('/support'),
                  isDark: isDark,
                  isLast: true,
                ),
              ], isDark),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.error.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out of SalonVerse',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'SalonVerse v2.0.0 • Production Build',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isDark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark ? null : AppSpacing.softShadow(context),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isLast = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(),
      ],
    );
  }
}
