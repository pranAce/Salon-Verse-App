import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/widgets/app_button.dart';
import 'package:salonverse/widgets/app_text_field.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

/// Login mode determines which post-login destination the user is routed to.
enum LoginMode { customer, salon }

class LoginPage extends StatefulWidget {
  final LoginMode loginMode;

  const LoginPage({super.key, this.loginMode = LoginMode.customer});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _isSalonMode => widget.loginMode == LoginMode.salon;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;

      if (_isSalonMode) {
        // Salon mode: verify user has salon role
        if (user != null && user.isSalonRole) {
          AppFeedback.success(context, 'Welcome back, ${user.name}!');
          context.go('/salon-workspace/dashboard');
        } else {
          AppFeedback.error(
            context,
            'This account does not have salon access. Please use "Continue as Customer" instead.',
          );
          await authProvider.logout();
        }
      } else {
        // Customer mode: verify user does not have salon role
        if (user != null && user.isSalonRole) {
          AppFeedback.error(
            context,
            'This is a salon operator account. Please use "Login as Salon" instead.',
          );
          await authProvider.logout();
        } else {
          AppFeedback.success(context, 'Welcome back!');
          context.go('/home');
        }
      }
    } else {
      AppFeedback.error(context, authProvider.error ?? 'Login failed.');
    }
  }

  Future<void> _handleQuickLogin({
    required String email,
    required String password,
  }) async {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;
      AppFeedback.success(context, 'Welcome back, ${user?.name ?? 'User'}!');
      if (user != null && user.isSalonRole) {
        context.go('/salon-workspace/dashboard');
      } else {
        context.go('/home');
      }
    } else {
      AppFeedback.error(context, authProvider.error ?? 'Login failed.');
    }
  }

  Widget _buildQuickLoginCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C1B) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(isDark ? 30 : 60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFFEC4899)),
              SizedBox(width: 6),
              Text(
                'Quick Login (Test Accounts)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.person_rounded, size: 16, color: Color(0xFFEC4899)),
                label: const Text('Test Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                backgroundColor: isDark ? const Color(0xFF2A2726) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _handleQuickLogin(
                  email: 'user@salonverse.live',
                  password: '12345678',
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFF3B82F6)),
                label: const Text('Salon Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                backgroundColor: isDark ? const Color(0xFF2A2726) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _handleQuickLogin(
                  email: 'salon_admin@salonverse.live',
                  password: '12345678',
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.content_cut_rounded, size: 16, color: Color(0xFF10B981)),
                label: const Text('Salon Staff', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                backgroundColor: isDark ? const Color(0xFF2A2726) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _handleQuickLogin(
                  email: 'salon_staff@salonverse.live',
                  password: '12345678',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mode Indicator & Logo
                        Center(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withAlpha(20),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Headers
                        Center(
                          child: Text(
                            _isSalonMode ? 'Salon Login' : 'Welcome Back',
                            style:
                                theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _isSalonMode
                                ? 'Sign in to manage your salon operations'
                                : 'Sign in to discover and book beauty sessions',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        // Mode badge
                        if (_isSalonMode) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withAlpha(15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withAlpha(40),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Salon Staff & Admin Access',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 36),

                        // Email
                        AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your email.';
                            }
                            if (!val.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 12),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/auth/forgot-password');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        AppButton(
                          label: _isSalonMode ? 'Sign In to Salon' : 'Login',
                          isLoading: authProvider.isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),

                        // Quick Login (Test Accounts) Section
                        _buildQuickLoginCard(theme, isDark),
                        const SizedBox(height: 20),

                        // Footer: Register or Switch mode
                        if (!_isSalonMode) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/auth/register'),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Switch login mode
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              if (_isSalonMode) {
                                context.go('/auth/login');
                              } else {
                                context.go('/auth/login',
                                    extra: {'loginMode': 'salon'});
                              }
                            },
                            icon: Icon(
                              _isSalonMode
                                  ? Icons.person_outline_rounded
                                  : Icons.storefront_outlined,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            label: Text(
                              _isSalonMode
                                  ? 'Continue as Customer instead'
                                  : 'Login as Salon instead',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
