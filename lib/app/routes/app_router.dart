import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/core/constants/app_constants.dart';
import 'package:salonverse/app/theme/app_theme.dart';

import 'package:salonverse/features/auth/presentation/welcome_page.dart';
import 'package:salonverse/features/auth/presentation/onboarding_page.dart';
import 'package:salonverse/features/auth/presentation/login_page.dart';
import 'package:salonverse/features/auth/presentation/register_page.dart';
import 'package:salonverse/features/auth/presentation/forgot_password_page.dart';

import 'package:salonverse/features/home/presentation/main_shell.dart';
import 'package:salonverse/features/home/presentation/home_screen.dart';
import 'package:salonverse/features/booking/presentation/booking_history_page.dart';
import 'package:salonverse/features/salons/presentation/salons_directory_page.dart';
import 'package:salonverse/features/profile/presentation/profile_page.dart';

import 'package:salonverse/features/salons/presentation/salon_detail_screen.dart';
import 'package:salonverse/features/booking/presentation/booking_flow_page.dart';
import 'package:salonverse/features/booking/presentation/payment_confirmation_page.dart';
import 'package:salonverse/features/profile/presentation/account_page.dart';
import 'package:salonverse/features/profile/presentation/refer_page.dart';
import 'package:salonverse/features/profile/presentation/favorites_page.dart';
import 'package:salonverse/features/profile/presentation/addresses_page.dart';
import 'package:salonverse/features/profile/presentation/payments_page.dart';
import 'package:salonverse/features/loyalty/presentation/offers_page.dart';
import 'package:salonverse/features/loyalty/presentation/loyalty_home_page.dart';
import 'package:salonverse/features/loyalty/presentation/rewards_store_page.dart';
import 'package:salonverse/features/loyalty/presentation/my_vouchers_page.dart';
import 'package:salonverse/features/loyalty/presentation/how_to_earn_page.dart';
import 'package:salonverse/features/loyalty/presentation/points_history_page.dart';
import 'package:salonverse/features/notifications/presentation/notifications_page.dart';

import 'package:salonverse/features/support/presentation/support_page.dart';
import 'package:salonverse/features/support/presentation/contact_support_page.dart';
import 'package:salonverse/features/support/presentation/contact_detail_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _customerShellKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _fadeTransitionPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppPageTransitions.normal,
    reverseTransitionDuration: AppPageTransitions.fast,
    transitionsBuilder: AppPageTransitions.fadeThrough,
  );
}

CustomTransitionPage<void> _slideRightPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppPageTransitions.normal,
    reverseTransitionDuration: AppPageTransitions.fast,
    transitionsBuilder: AppPageTransitions.slideFromRight,
  );
}

CustomTransitionPage<void> _slideBottomPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppPageTransitions.normal,
    reverseTransitionDuration: AppPageTransitions.fast,
    transitionsBuilder: AppPageTransitions.slideFromBottom,
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  refreshListenable: AppService.instance.auth.currentUserNotifier,
  initialLocation: '/',
  redirect: (context, state) {
    final prefs = AppServices.prefs;
    final onboardingSeen = prefs.getBool(KConstants.onboardingSeenKey) ?? false;
    final loc = state.matchedLocation;

    if (!onboardingSeen) {
      if (loc == '/welcome' || loc == '/onboarding') return null;
      return '/welcome';
    }

    final isLoggedIn = AppService.instance.currentUser != null;
    final isAuthRoute = loc.startsWith('/auth');
    final isOnboardingRoute = loc == '/welcome' || loc == '/onboarding';

    if (loc == '/') {
      if (isLoggedIn) {
        return '/home';
      } else {
        return '/auth/login';
      }
    }

    if (!isLoggedIn && !isAuthRoute && !isOnboardingRoute) {
      return '/auth/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(child: const WelcomePage(), state: state),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(child: const OnboardingPage(), state: state),
    ),

    GoRoute(
      path: '/auth/login',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(child: const LoginPage(), state: state),
    ),
    GoRoute(
      path: '/auth/register',
      pageBuilder: (context, state) =>
          _fadeTransitionPage(child: const RegisterPage(), state: state),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const ForgotPasswordPage(), state: state),
    ),

    ShellRoute(
      navigatorKey: _customerShellKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(child: const HomeScreen(), state: state),
        ),
        GoRoute(
          path: '/bookings',
          pageBuilder: (context, state) => _fadeTransitionPage(
            child: const BookingHistoryPage(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/salon-tab',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(child: const SalonsDirectoryPage(), state: state),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(child: const ProfilePage(), state: state),
        ),
      ],
    ),

    GoRoute(
      path: '/salon/:id',
      pageBuilder: (context, state) {
        final salonId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        final salon = extra?['salon'];
        return _slideRightPage(
          child: SalonDetailScreen(salonId: salonId, preloadedSalon: salon),
          state: state,
        );
      },
    ),
    GoRoute(
      path: '/booking-flow',
      pageBuilder: (context, state) =>
          _slideBottomPage(child: const BookingFlowPage(), state: state),
    ),
    GoRoute(
      path: '/payment-confirmation',
      pageBuilder: (context, state) => _slideBottomPage(
        child: const PaymentConfirmationPage(),
        state: state,
      ),
    ),
    GoRoute(
      path: '/loyalty',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const LoyaltyHomePage(), state: state),
    ),
    GoRoute(
      path: '/loyalty/earn',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const HowToEarnPage(), state: state),
    ),
    GoRoute(
      path: '/loyalty/rewards',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const RewardsStorePage(), state: state),
    ),
    GoRoute(
      path: '/loyalty/vouchers',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const MyVouchersPage(), state: state),
    ),
    GoRoute(
      path: '/loyalty/history',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const PointsHistoryPage(), state: state),
    ),
    GoRoute(
      path: '/profile/account',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const AccountPage(), state: state),
    ),
    GoRoute(
      path: '/profile/refer',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const ReferPage(), state: state),
    ),
    GoRoute(
      path: '/profile/favorites',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const FavoritesPage(), state: state),
    ),

    GoRoute(
      path: '/profile/addresses',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const AddressesPage(), state: state),
    ),
    GoRoute(
      path: '/profile/payments',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const PaymentsPage(), state: state),
    ),
    GoRoute(
      path: '/profile/offers',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const OffersPage(), state: state),
    ),
    GoRoute(
      path: '/offers',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const OffersPage(), state: state),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const NotificationsPage(), state: state),
    ),

    GoRoute(
      path: '/support',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const SupportPage(), state: state),
    ),
    GoRoute(
      path: '/support/contact',
      pageBuilder: (context, state) =>
          _slideRightPage(child: const ContactSupportPage(), state: state),
    ),
    GoRoute(
      path: '/support/detail/:id',
      pageBuilder: (context, state) {
        final ticketId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        final subject = extra?['subject'] as String? ?? 'Support Ticket';
        return _slideRightPage(
          child: ContactDetailPage(ticketId: ticketId, subject: subject),
          state: state,
        );
      },
    ),
  ],
);
