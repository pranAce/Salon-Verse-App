import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/subscription_provider.dart';
import 'package:salonverse/models/subscription_model.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class SubscriptionManagePage extends StatefulWidget {
  const SubscriptionManagePage({super.key});

  @override
  State<SubscriptionManagePage> createState() => _SubscriptionManagePageState();
}

class _SubscriptionManagePageState extends State<SubscriptionManagePage> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadSubscription();
      _isInit = false;
    }
  }

  Future<void> _loadSubscription() async {
    final user = context.read<AuthProvider>().currentUser;
    final salonId = user?.salonId;
    await context.read<SubscriptionProvider>().fetchCurrentSubscription(salonId);
  }

  void _showChangePlanModal(BuildContext context, SubscriptionModel currentSub) {
    final theme = Theme.of(context);
    final user = context.read<AuthProvider>().currentUser;
    final salonId = user?.salonId ?? '';

    String selectedPlan = currentSub.plan == 'basic' ? 'premium' : 'basic';
    String selectedMethod = 'esewa';
    final refController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Request Plan Change",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // STRICT BACKEND BANNER RULE
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.withAlpha(80)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.amber, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "All plan changes take effect at the NEXT BILLING CYCLE. There are no immediate switches.",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Select Target Plan",
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Text(
                                "BASIC\nNPR 300/mo (7%)",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            selected: selectedPlan == 'basic',
                            onSelected: (val) {
                              if (val) setModalState(() => selectedPlan = 'basic');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(
                              child: Text(
                                "PREMIUM\nNPR 600/mo (5%)",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            selected: selectedPlan == 'premium',
                            onSelected: (val) {
                              if (val) setModalState(() => selectedPlan = 'premium');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Payment Method",
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      items: const [
                        DropdownMenuItem(value: "esewa", child: Text("eSewa")),
                        DropdownMenuItem(value: "khalti", child: Text("Khalti")),
                        DropdownMenuItem(value: "cash", child: Text("Cash / Offline Verification")),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedMethod = val);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: refController,
                      decoration: const InputDecoration(
                        labelText: "Payment Reference / Txn ID",
                        hintText: "e.g. ESEWA-981244",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: "Notes (Optional)",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final ref = refController.text.trim();
                                if (ref.isEmpty && selectedMethod != 'cash') {
                                  AppFeedback.error(ctx, "Please enter payment reference number.");
                                  return;
                                }

                                setModalState(() => isSubmitting = true);

                                bool ok;
                                final provider = context.read<SubscriptionProvider>();

                                if (selectedMethod == 'cash') {
                                  ok = await provider.submitManualPayment(
                                    salonId: salonId,
                                    plan: selectedPlan,
                                    paymentMethod: selectedMethod,
                                    paymentReference: ref.isEmpty ? null : ref,
                                    notes: notesController.text.trim(),
                                  );
                                } else {
                                  ok = await provider.processOnlinePayment(
                                    salonId: salonId,
                                    plan: selectedPlan,
                                    paymentMethod: selectedMethod,
                                    paymentReference: ref,
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  if (ok) {
                                    AppFeedback.success(
                                      context,
                                      "Plan change scheduled for next billing cycle!",
                                    );
                                  } else {
                                    AppFeedback.error(
                                      context,
                                      provider.error ?? "Failed to submit plan change request.",
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Schedule Plan Change",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SubscriptionProvider>();

    final sub = provider.subscription;
    final isLoading = provider.isLoading;
    final error = provider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subscription & Billing",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadSubscription,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading && sub == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadSubscription,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withAlpha(50)),
                          ),
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),

                      if (sub != null) ...[
                        // CURRENT PLAN CARD
                        _buildCurrentPlanCard(context, sub, theme),
                        const SizedBox(height: 20),

                        // SCHEDULED NEXT PLAN CARD (IF ANY)
                        if (sub.hasScheduledChange) ...[
                          _buildScheduledPlanCard(context, sub, theme),
                          const SizedBox(height: 20),
                        ],

                        // CHANGE PLAN ACTION BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: Text(
                              sub.hasScheduledChange
                                  ? "Update Scheduled Plan"
                                  : "Change Subscription Plan",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _showChangePlanModal(context, sub),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ALLOWED & RESTRICTED FEATURES
                        Text(
                          "Plan Features & Entitlements",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...provider.allowedFeatures.map(
                                (feat) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: Colors.green, size: 18),
                                      const SizedBox(width: 10),
                                      Text(
                                        feat.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ...provider.restrictedFeatures.map(
                                (feat) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.cancel_rounded,
                                          color: Colors.grey.shade400, size: 18),
                                      const SizedBox(width: 10),
                                      Text(
                                        feat.replaceAll('_', ' ').toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // PAYMENT HISTORY
                        Text(
                          "Payment & Billing History",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (provider.payments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No payment history records found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...provider.payments.map((p) => _buildPaymentItem(p, theme)),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, SubscriptionModel sub, ThemeData theme) {
    final endDateStr = sub.endDate != null
        ? "${sub.endDate!.day}/${sub.endDate!.month}/${sub.endDate!.year}"
        : "N/A";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: sub.plan == 'premium'
              ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
              : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (sub.plan == 'premium' ? Colors.purple : Colors.blue).withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "CURRENT PLAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sub.isActive ? Colors.green.shade400 : Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sub.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            sub.formattedPlanName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "NPR ${sub.price.toInt()}/month • ${sub.formattedCommission} commission",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Active until: $endDateStr",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                "Auto-renew: ${sub.autoRenew ? 'ON' : 'OFF'}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledPlanCard(BuildContext context, SubscriptionModel sub, ThemeData theme) {
    final effectiveStr = sub.nextPlanEffectiveDate != null
        ? "${sub.nextPlanEffectiveDate!.day}/${sub.nextPlanEffectiveDate!.month}/${sub.nextPlanEffectiveDate!.year}"
        : "Next Billing Date";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade400, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "SCHEDULED CHANGE",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                "Effective: $effectiveStr",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (sub.nextPlan ?? '').toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Change scheduled for next billing cycle. Current plan remains active until $effectiveStr.",
            style: TextStyle(
              fontSize: 12.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),

          // CANCEL SCHEDULED CHANGE BUTTON
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text(
                "Cancel Scheduled Change",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () async {
                final user = context.read<AuthProvider>().currentUser;
                final salonId = user?.salonId;

                final ok = await context
                    .read<SubscriptionProvider>()
                    .cancelScheduledChange(salonId);

                if (context.mounted) {
                  if (ok) {
                    AppFeedback.success(
                      context,
                      "Scheduled plan change cancelled. Current plan will remain active.",
                    );
                  } else {
                    AppFeedback.error(
                      context,
                      context.read<SubscriptionProvider>().error ??
                          "Failed to cancel scheduled change.",
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(SubscriptionPaymentModel p, ThemeData theme) {
    Color statusColor = Colors.grey;
    if (p.status == 'completed') statusColor = Colors.green;
    if (p.status == 'pending') statusColor = Colors.orange;
    if (p.status == 'failed') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NPR ${p.amount.toInt()} • ${p.plan.toUpperCase()}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                "${p.paymentMethod.toUpperCase()} • Ref: ${p.paymentReference}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withAlpha(80)),
            ),
            child: Text(
              p.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
