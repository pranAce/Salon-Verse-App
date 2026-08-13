import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/services/api_result.dart';
import 'package:salonverse/models/support_ticket_model.dart';
import 'package:salonverse/widgets/app_button.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  List<SupportTicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    final res = await AppService.instance.getSupportTickets();
    if (res is Success<List<SupportTicketModel>>) {
      setState(() {
        _tickets = res.data;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Glowing Help Desk Illustration/Header Bubble
                          Center(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.support_agent_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "How can we help you?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Search FAQs or file an official ticket below.",
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(200),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 2. Collapsible FAQs Panel (Grouped inside a card)
                          Text(
                            "Frequently Asked Questions",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 25 : 55)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 0 : 3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [
                                ExpansionTile(
                                  title: Text("How do I cancel or reschedule?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  childrenPadding: EdgeInsets.all(16),
                                  children: [
                                    Text(
                                      "Navigate to the Bookings tab, select your upcoming booking, and tap the Reschedule or Cancel button.",
                                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                                    )
                                  ],
                                ),
                                Divider(height: 1),
                                ExpansionTile(
                                  title: Text("What are the payment methods?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  childrenPadding: EdgeInsets.all(16),
                                  children: [
                                    Text(
                                      "We support online eSewa wallets, card systems, and Pay at Salon alternatives.",
                                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                                    )
                                  ],
                                ),
                                Divider(height: 1),
                                ExpansionTile(
                                  title: Text("Are stylist bookings guaranteed?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  childrenPadding: EdgeInsets.all(16),
                                  children: [
                                    Text(
                                      "Yes. When you book a specific operator, they are assigned to your queue ticket. You can track your number on the app.",
                                      style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 3. Direct Support Channels (Grouped Card)
                          Text(
                            "Contact Support Channels",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 25 : 55)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 0 : 3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.phone_rounded, color: theme.colorScheme.primary),
                                  title: const Text("Call Customer Helpline", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  subtitle: const Text("+977 1 4567890", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                  onTap: () {},
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Divider(height: 1),
                                ),
                                ListTile(
                                  leading: Icon(Icons.email_rounded, color: theme.colorScheme.primary),
                                  title: const Text("Email Support Team", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  subtitle: const Text("support@salonverse.com", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 4. Ticket History List
                          Text(
                            "My Support Requests",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _tickets.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 45)),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No active support requests.",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _tickets
                                      .map((ticket) => _buildTicketTile(context, ticket))
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ),

                  // Submit Ticket Trigger
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppButton(
                      label: "Create Support Request",
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () async {
                        await context.push('/support/contact');
                        _loadTickets();
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTicketTile(BuildContext context, SupportTicketModel ticket) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isClosed = ticket.status == 'Closed';
    final isAnswered = ticket.status == 'Answered';

    final statusColor = isClosed
        ? Colors.grey
        : isAnswered
            ? Colors.green
            : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 25 : 55)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          await context.push(
            '/support/detail/${ticket.id}',
            extra: {'subject': ticket.subject},
          );
          _loadTickets();
        },
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(20),
          child: Icon(
            isClosed
                ? Icons.lock_outline_rounded
                : Icons.question_answer_outlined,
            color: statusColor,
          ),
        ),
        title: Text(
          ticket.subject,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          'Status: ${ticket.status}',
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      ),
    );
  }
}
