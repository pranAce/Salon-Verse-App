import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/support/services/support_service.dart';
import 'package:salonverse/features/auth/services/auth_service.dart';
import 'package:salonverse/features/support/models/support_ticket_model.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/widgets/sv_button.dart';
import 'package:salonverse/core/widgets/sv_feedback_states.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  List<SupportTicketModel> _tickets = [];
  bool _isLoading = true;

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I cancel or reschedule my appointment?',
      'a':
          'Go to the "Bookings" tab from the bottom navigation bar. Select your upcoming appointment and tap "Reschedule" or "Cancel". Free cancellations are allowed up to 2 hours before the scheduled time slot.',
    },
    {
      'q': 'How are SalonVerse loyalty points calculated?',
      'a':
          'You earn 10 points for every Rs. 100 spent on completed salon bookings. Points can be redeemed in the Rewards Store for discount vouchers and exclusive service upgrades.',
    },
    {
      'q': 'What payment methods are supported?',
      'a':
          'We support cash / pay-at-salon on arrival, digital wallets (eSewa, Khalti), and major Credit / Debit cards (Visa, Mastercard).',
    },
    {
      'q': 'How does doorstep / home service work?',
      'a':
          'When booking, toggle the "Home Service" option. Enter your exact street address. A verified beauty specialist from the salon will bring professional equipment to your location at your selected time.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTickets();
    });
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final res = await SupportService().getSupportTickets(
      AuthService().currentUser,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res is Success<List<SupportTicketModel>>) {
          _tickets = res.data;
        }
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Support & Help',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                itemCount: 3,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SVSkeleton(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 16,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        boxShadow: isDark
                            ? null
                            : AppSpacing.softShadow(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Direct Assistance',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Our support desk is active daily from 8:00 AM to 9:00 PM.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: SVButton(
                                  text: 'Call Us',
                                  size: SVButtonSize.sm,
                                  variant: SVButtonVariant.secondary,
                                  icon: Icons.phone_outlined,
                                  onPressed: () =>
                                      _launchUrl('tel:+9779800000000'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SVButton(
                                  text: 'Email Desk',
                                  size: SVButtonSize.sm,
                                  variant: SVButtonVariant.outline,
                                  icon: Icons.email_outlined,
                                  onPressed: () => _launchUrl(
                                    'mailto:support@salonverse.com',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Support Tickets',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context
                              .push('/support/contact')
                              .then((_) => _loadTickets()),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('New Ticket'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (_tickets.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.mark_chat_read_outlined,
                              size: 32,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No Active Support Inquiries',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._tickets.map((t) {
                        return GestureDetector(
                          onTap: () => context.push(
                            '/support/detail/${t.id}',
                            extra: {'subject': t.subject},
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.status.toLowerCase() == 'open'
                                        ? AppColors.primary.withAlpha(25)
                                        : Colors.grey.withAlpha(30),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    t.status.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: t.status.toLowerCase() == 'open'
                                          ? AppColors.primary
                                          : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.subject,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Ticket #${t.id.substring(0, 6).toUpperCase()}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
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
                        );
                      }),

                    const SizedBox(height: 24),

                    Text(
                      'Frequently Asked Questions',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ..._faqs.map((faq) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Theme(
                          data: theme.copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              14,
                              0,
                              14,
                              14,
                            ),
                            title: Text(
                              faq['q']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            children: [
                              Text(
                                faq['a']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
