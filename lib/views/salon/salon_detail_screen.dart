import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/controllers/salon_provider.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class SalonDetailScreen extends StatefulWidget {
  final String salonId;
  final SalonModel? preloadedSalon;

  const SalonDetailScreen({
    super.key,
    required this.salonId,
    this.preloadedSalon,
  });

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  SalonModel? _salon;
  bool _isAboutExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadSalon();
  }

  void _loadSalon() {
    if (widget.preloadedSalon != null) {
      _salon = widget.preloadedSalon;
    } else {
      final salons = context.read<SalonProvider>().salons;
      try {
        _salon = salons.firstWhere((s) => s.id == widget.salonId);
      } catch (_) {
        _salon = null;
        context.read<SalonProvider>().fetchSalons().then((_) {
          if (mounted) {
            final updatedSalons = context.read<SalonProvider>().salons;
            setState(() {
              try {
                _salon = updatedSalons.firstWhere(
                  (s) => s.id == widget.salonId,
                );
              } catch (_) {
                _salon = null;
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_salon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salon Details')),
        body: const Center(child: Text('Salon not found.')),
      );
    }

    final user = context.watch<AuthProvider>().currentUser;
    final isFav = user?.favoriteSalons.contains(_salon!.id) ?? false;

    final minPrice = _salon!.services.isNotEmpty
        ? _salon!.services
              .map((s) => s.price)
              .reduce((a, b) => a < b ? a : b)
              .round()
        : 1200;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _salon!.imageUrl,
                      width: double.infinity,
                      height: 320,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 320,
                        color: theme.colorScheme.surfaceContainer,
                      ),
                      errorWidget: (context, url, err) => Container(
                        height: 320,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 64,
                          color: Colors.white12,
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(80),
                              Colors.transparent,
                              Colors.black.withAlpha(60),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -28,
                      left: 24,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1C1B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 30 : 12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.outline.withAlpha(
                              isDark ? 30 : 60,
                            ),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _salon!.name.isNotEmpty
                              ? _salon!.name[0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _salon!.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF2E7D32),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Verified",
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${_salon!.address}, ${_salon!.city} • 0.8 km',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          theme,
                          Icon(
                            Icons.star_rounded,
                            color: Colors.pink.shade300,
                            size: 20,
                          ),
                          '${_salon!.rating}',
                          '${_salon!.reviewCount} reviews',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          theme,
                          Icon(
                            Icons.access_time_filled_rounded,
                            color: Colors.pink.shade300,
                            size: 20,
                          ),
                          _salon!.openingHours.isNotEmpty
                              ? _salon!.openingHours.split('-')[0].trim()
                              : '9:00 AM',
                          _salon!.openingHours.isNotEmpty
                              ? _salon!.openingHours
                              : 'Open Today',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            AppFeedback.success(
                              context,
                              "Calling ${_salon!.name}...",
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: _buildInfoCard(
                            context,
                            theme,
                            Icon(
                              Icons.phone_in_talk_rounded,
                              color: Colors.pink.shade300,
                              size: 20,
                            ),
                            'Call',
                            _salon!.phoneNumber.isNotEmpty
                                ? _salon!.phoneNumber
                                : 'Call Salon',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About ${_salon!.name}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _salon!.description.isNotEmpty
                            ? "${_salon!.name} is located at ${_salon!.address}, ${_salon!.city}. ${_salon!.description}"
                            : "${_salon!.name} is located at ${_salon!.address}, ${_salon!.city}. A top-rated salon in ${_salon!.city} offering haircutting, styling, skin care, and beauty treatments.",
                        maxLines: _isAboutExpanded ? 100 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAboutExpanded = !_isAboutExpanded;
                          });
                        },
                        child: Text(
                          _isAboutExpanded ? "Read less" : "... View more",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                if (_salon!.services.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Available Services (${_salon!.services.length})",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ..._salon!.services.map((svc) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1C1B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: theme.colorScheme.outline.withAlpha(
                                  isDark ? 25 : 45,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 0 : 4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(
                                    0xFFEC4899,
                                  ).withAlpha(18),
                                  child: const Icon(
                                    Icons.spa_rounded,
                                    color: Color(0xFFEC4899),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        svc.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white10
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              svc.category.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white70
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${svc.durationMinutes} mins",
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Rs. ${svc.price.round()}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: Color(0xFFEC4899),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<BookingProvider>()
                                            .startBookingFlow(_salon!, svc);
                                        context.push('/booking-flow');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEC4899),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          "Book",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                if (_salon!.stylists.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Featured Stylists (${_salon!.stylists.length})",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _salon!.stylists.length,
                            itemBuilder: (context, index) {
                              final st = _salon!.stylists[index];
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1C1B)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withAlpha(
                                      isDark ? 20 : 40,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: st.imageUrl.isNotEmpty
                                          ? NetworkImage(st.imageUrl)
                                          : null,
                                      child: st.imageUrl.isEmpty
                                          ? const Icon(Icons.person, size: 20)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            st.name.split(' ')[0],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            st.specialty,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 120),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161514) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withAlpha(
                      isDark ? 30 : 60,
                    ),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Starting from",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs. $minPrice',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          context
                              .read<BookingProvider>()
                              .startBookingFlowForSalon(_salon!);
                          context.push('/booking-flow');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Book Appointment",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: _buildCircularButton(
              context,
              Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                size: 20,
              ),
              () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: Row(
              children: [
                _buildCircularButton(
                  context,
                  Icon(
                    Icons.share_outlined,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    size: 20,
                  ),
                  () {
                    AppFeedback.success(context, "Link copied to clipboard!");
                  },
                ),
                const SizedBox(width: 10),
                _buildCircularButton(
                  context,
                  Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav
                        ? Colors.red
                        : (isDark ? Colors.white : AppColors.lightTextPrimary),
                    size: 20,
                  ),
                  () {
                    context.read<AuthProvider>().toggleFavorite(_salon!.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(
    BuildContext context,
    Widget child,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF221F1C).withAlpha(200)
              : Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme,
    Widget icon,
    String title,
    String subtitle,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
        ),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
