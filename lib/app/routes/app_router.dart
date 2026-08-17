import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/core/constants/app_constants.dart';

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

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final GlobalKey<NavigatorState> _customerShellKey = GlobalKey<NavigatorState>(debugLabel: 'shellNav');

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
      parentNavigatorKey: rootNavigatorKey,
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/auth/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/auth/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    ShellRoute(
      navigatorKey: _customerShellKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const BookingHistoryPage(),
        ),
        GoRoute(
          path: '/salon-tab',
          builder: (context, state) => const SalonsDirectoryPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/salon/:id',
      builder: (context, state) {
        final salonId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        final salon = extra?['salon'];
        return SalonDetailScreen(salonId: salonId, preloadedSalon: salon);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/booking-flow',
      builder: (context, state) => const BookingFlowPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/payment-confirmation',
      builder: (context, state) => const PaymentConfirmationPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/loyalty',
      builder: (context, state) => const LoyaltyHomePage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/loyalty/earn',
      builder: (context, state) => const HowToEarnPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/loyalty/rewards',
      builder: (context, state) => const RewardsStorePage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/loyalty/vouchers',
      builder: (context, state) => const MyVouchersPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/loyalty/history',
      builder: (context, state) => const PointsHistoryPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/profile/account',
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/profile/refer',
      builder: (context, state) => const ReferPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/profile/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/profile/addresses',
      builder: (context, state) => const AddressesPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/profile/payments',
      builder: (context, state) => const PaymentsPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/profile/offers',
      builder: (context, state) => const OffersPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/offers',
      builder: (context, state) => const OffersPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/support',
      builder: (context, state) => const SupportPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/support/contact',
      builder: (context, state) => const ContactSupportPage(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/support/detail/:id',
      builder: (context, state) {
        final ticketId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        final subject = extra?['subject'] as String? ?? 'Support Ticket';
        return ContactDetailPage(ticketId: ticketId, subject: subject);
      },
    ),
  ],
);
