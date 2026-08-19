import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _logoScale;
  late final Animation<double> _buttonsFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _buttonsFade = CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
            // Background Glow Circles
            Positioned(
              top: -size.width * 0.2,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withAlpha(isDark ? 30 : 25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo & App Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: AppSpacing.glowShadow(AppColors.primary, opacity: 0.35),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    decoration: const BoxDecoration(
                                      gradient: AppGradients.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 48),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'SalonVerse',
                              style: GoogleFonts.outfit(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'DISCOVER  •  BOOK  •  GLOW',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                letterSpacing: 3.5,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Hero Description
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _buttonsFade,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your Next-Gen Beauty\n& Wellness Sanctuary',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Discover premier salons, choose elite stylists, track live queue tokens, and claim VIP rewards.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // CTA Button
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _buttonsFade,
                        child: SVButton(
                          text: 'Get Started',
                          isFullWidth: true,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => context.go('/onboarding'),
                        ),
                      ),
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
