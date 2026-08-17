import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/core/constants/app_constants.dart';
import 'package:salonverse/theme/app_theme.dart';

import 'package:salonverse/views/auth/welcome_page.dart';
import 'package:salonverse/views/auth/onboarding_page.dart';
import 'package:salonverse/views/auth/login_page.dart';
import 'package:salonverse/views/auth/register_page.dart';
import 'package:salonverse/views/auth/forgot_password_page.dart';

import 'package:salonverse/views/shell/main_shell.dart';
import 'package:salonverse/views/home/home_screen.dart';
import 'package:salonverse/views/booking/booking_history_page.dart';
import 'package:salonverse/views/salon/salons_tab_page.dart';
import 'package:salonverse/views/profile/profile_page.dart';

import 'package:salonverse/views/salon/salon_detail_screen.dart';
import 'package:salonverse/views/salon/booking_flow_page.dart';
import 'package:salonverse/views/salon/payment_confirmation_page.dart';
import 'package:salonverse/views/profile/account_page.dart';
import 'package:salonverse/views/profile/refer_page.dart';
import 'package:salonverse/views/profile/favorites_page.dart';
import 'package:salonverse/views/profile/addresses_page.dart';
import 'package:salonverse/views/profile/payments_page.dart';
import 'package:salonverse/views/profile/offers_page.dart';
import 'package:salonverse/views/profile/loyalty_home_page.dart';
import 'package:salonverse/views/profile/rewards_store_page.dart';
import 'package:salonverse/views/profile/my_vouchers_page.dart';
import 'package:salonverse/views/notifications/notifications_page.dart';


import 'package:salonverse/views/support/support_page.dart';
import 'package:salonverse/views/support/contact_support_page.dart';
import 'package:salonverse/views/support/contact_detail_page.dart';

import 'package:salonverse/views/admin_workspace/salon_admin_dashboard.dart';
import 'package:salonverse/views/admin_workspace/salon_admin_services.dart';
import 'package:salonverse/views/admin_workspace/salon_admin_staff.dart';
import 'package:salonverse/views/admin_workspace/salon_admin_settings.dart';
import 'package:salonverse/views/admin_workspace/subscription_manage_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _customerShellKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _salonShellKey = GlobalKey<NavigatorState>();

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
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final modeStr = extra?['loginMode'] as String?;
        final mode = modeStr == 'salon' ? LoginMode.salon : LoginMode.customer;
        return _fadeTransitionPage(
          child: LoginPage(loginMode: mode),
          state: state,
        );
      },
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
              _fadeTransitionPage(child: const SalonsTabPage(), state: state),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(child: const ProfilePage(), state: state),
        ),
      ],
    ),

    ShellRoute(
      navigatorKey: _salonShellKey,
      builder: (context, state, child) => _SalonWorkspaceShell(child: child),
      routes: [
        GoRoute(
          path: '/salon-workspace/dashboard',
          pageBuilder: (context, state) => _fadeTransitionPage(
            child: const SalonAdminDashboard(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/salon-workspace/services',
          pageBuilder: (context, state) => _fadeTransitionPage(
            child: const SalonAdminServices(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/salon-workspace/staff',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(child: const SalonAdminStaff(), state: state),
        ),
        GoRoute(
          path: '/salon-workspace/settings',
          pageBuilder: (context, state) => _fadeTransitionPage(
            child: const SalonAdminSettings(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/salon-workspace/subscription',
          pageBuilder: (context, state) => _slideRightPage(
            child: const SubscriptionManagePage(),
            state: state,
          ),
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

class _SalonWorkspaceShell extends StatelessWidget {
  final Widget child;

  const _SalonWorkspaceShell({required this.child});

  int _calculateIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/salon-workspace/dashboard')) return 0;
    if (loc.startsWith('/salon-workspace/services')) return 1;
    if (loc.startsWith('/salon-workspace/staff')) return 2;
    if (loc.startsWith('/salon-workspace/settings')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/salon-workspace/dashboard');
        break;
      case 1:
        context.go('/salon-workspace/services');
        break;
      case 2:
        context.go('/salon-workspace/staff');
        break;
      case 3:
        context.go('/salon-workspace/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = _calculateIndex(context);
    final user = AppService.instance.currentUser;

    final isStaffOnly = user?.isSalonStaff ?? false;

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
      if (!isStaffOnly) ...[
        const NavigationDestination(
          icon: Icon(Icons.dry_cleaning_outlined),
          selectedIcon: Icon(Icons.dry_cleaning_rounded),
          label: 'Services',
        ),
        const NavigationDestination(
          icon: Icon(Icons.people_outline_rounded),
          selectedIcon: Icon(Icons.people_rounded),
          label: 'Staff',
        ),
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront_rounded),
          label: 'Settings',
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForIndex(selectedIndex, isStaffOnly),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isStaffOnly)
            IconButton(
              icon: const Icon(Icons.card_membership_rounded),
              tooltip: 'Subscription & Billing',
              onPressed: () => context.push('/salon-workspace/subscription'),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: isStaffOnly
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withAlpha(
                      isDark ? 40 : 80,
                    ),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) =>
                    _onDestinationSelected(context, index),
                destinations: destinations,
              ),
            ),
    );
  }

  String _getTitleForIndex(int index, bool isStaffOnly) {
    if (isStaffOnly) return 'My Appointments';
    switch (index) {
      case 0:
        return 'Salon Dashboard';
      case 1:
        return 'Services Directory';
      case 2:
        return 'Stylist Roster';
      case 3:
        return 'Salon Profile';
      default:
        return 'Salon Dashboard';
    }
  }
}
