import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/core/constants/app_constants.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

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
      title: 'Curated Beauty Discovery',
      description:
          'Explore top-rated verified salons and beauty artists across Nepal with authentic reviews and clear portfolio previews.',
    ),
    OnboardingSlide(
      icon: Icons.calendar_month_rounded,
      title: 'Real-Time Schedule & Queue',
      description:
          'Check dynamic stylist calendars, reserve slots instantly, and track your live queue token directly on your phone.',
    ),
    OnboardingSlide(
      icon: Icons.workspace_premium_rounded,
      title: 'Transparent Pay & VIP Perks',
      description:
          'No surprise charges. Pay seamlessly with eSewa, Khalti, or counter cash while accumulating VIP loyalty credits.',
    ),
  ];

  Future<void> _finishOnboarding() async {
    await AppServices.prefs.setBool(KConstants.onboardingSeenKey, true);
    if (mounted) {
      context.go('/auth/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SalonVerse',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_currentIndex < _slides.length - 1)
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                // Carousel Slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryTint,
                                boxShadow: AppSpacing.glowShadow(AppColors.primary, opacity: 0.2),
                              ),
                              child: Center(
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: const BoxDecoration(
                                    gradient: AppGradients.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(slide.icon, size: 44, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dots & CTA
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive ? AppColors.primary : AppColors.primary.withAlpha(50),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    SVButton(
                      text: _currentIndex < _slides.length - 1 ? 'Next' : 'Get Started',
                      isFullWidth: true,
                      onPressed: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
