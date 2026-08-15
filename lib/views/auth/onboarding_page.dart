import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/core/constants/app_constants.dart';
import 'package:salonverse/widgets/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.search_rounded,
      title: "Centralized Discovery",
      description:
          "Find verified beauty salons across Nepal. Filter by location, specific service categories, and ratings to compare premium options.",
    ),
    OnboardingSlide(
      icon: Icons.calendar_month_rounded,
      title: "Real-Time Booking",
      description:
          "Check live availability calendars for each salon and stylist. Book instantly and track your virtual queue position in real-time.",
    ),
    OnboardingSlide(
      icon: Icons.payments_outlined,
      title: "Transparent Pricing",
      description:
          "Browse clear menu prices upfront with zero hidden costs. Complete payments seamlessly using eSewa, Khalti, or cash at the counter.",
    ),
  ];

  Future<void> _selectRole(
    String routePath, {
    Map<String, dynamic>? extra,
  }) async {
    await AppServices.prefs.setBool(KConstants.onboardingSeenKey, true);
    if (mounted) {
      context.go(routePath, extra: extra);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F0E0D), const Color(0xFF1A1816)]
                      : [const Color(0xFFFDFBF7), const Color(0xFFF3EDE4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Positioned(
              top: -size.width * 0.2,
              left: -size.width * 0.1,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withAlpha(isDark ? 8 : 14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SalonVerse',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        if (_currentIndex < 2)
                          TextButton(
                            onPressed: () {
                              _pageController.animateToPage(
                                _slides.length - 1,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),

                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - (value.abs() * 0.15)).clamp(
                                  0.0,
                                  1.0,
                                );
                              }
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 148,
                                  height: 148,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withAlpha(20),
                                        theme.colorScheme.secondary.withAlpha(
                                          12,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withAlpha(30),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withAlpha(isDark ? 5 : 10),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 108,
                                      height: 108,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.secondary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Icon(
                                        slide.icon,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 48),

                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 16),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    slide.description,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (index) {
                            final isActive = index == _currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withAlpha(60),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 36),

                        if (_currentIndex < 2) ...[
                          AppButton(
                            label: "Next",
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            },
                          ),
                        ] else ...[
                          _WelcomeButton(
                            label: 'Continue as Customer',
                            subtitle: 'Browse salons & book appointments',
                            icon: Icons.explore_rounded,
                            isPrimary: true,
                            onTap: () => _selectRole(
                              '/auth/login',
                              extra: {'loginMode': 'customer'},
                            ),
                          ),
                          const SizedBox(height: 14),
                          _WelcomeButton(
                            label: 'Login as Salon',
                            subtitle: 'Manage your salon & staff operations',
                            icon: Icons.storefront_rounded,
                            isPrimary: false,
                            onTap: () => _selectRole(
                              '/auth/login',
                              extra: {'loginMode': 'salon'},
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _WelcomeButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _WelcomeButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_WelcomeButton> createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<_WelcomeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
    )..value = 1.0;
    _pressScale = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withAlpha(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPrimary
                ? null
                : (isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurface),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 1.5,
                  ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(
                        isDark ? 30 : 50,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.isPrimary
                      ? Colors.white.withAlpha(25)
                      : theme.colorScheme.primary.withAlpha(15),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isPrimary
                      ? Colors.white
                      : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.isPrimary
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isPrimary
                            ? Colors.white.withAlpha(180)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.isPrimary
                    ? Colors.white.withAlpha(160)
                    : theme.colorScheme.onSurfaceVariant.withAlpha(120),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
