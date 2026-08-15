import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_workspace_provider.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/models/booking_model.dart';
import 'package:salonverse/models/target_model.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class SalonAdminDashboard extends StatefulWidget {
  const SalonAdminDashboard({super.key});

  @override
  State<SalonAdminDashboard> createState() => _SalonAdminDashboardState();
}

class _SalonAdminDashboardState extends State<SalonAdminDashboard> {
  late final StreamController<List<Map<String, dynamic>>>
  _bookingsStreamController;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _bookingsStreamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalonWorkspaceProvider>().fetchDashboardMetrics();
      context.read<SalonWorkspaceProvider>().fetchTargets();
      _pollBookings();
      _pollingTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _pollBookings(),
      );
    });
  }

  Future<void> _pollBookings() async {
    if (!mounted || _bookingsStreamController.isClosed) return;
    try {
      final res = await AppService.instance.getBookings();
      if (res is Success<List<BookingModel>> &&
          !_bookingsStreamController.isClosed) {
        _bookingsStreamController.add(res.data.map((b) => b.toJson()).toList());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _bookingsStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final workspaceProvider = context.watch<SalonWorkspaceProvider>();
    final isStaff = user?.isSalonStaff ?? false;
    final isDark = theme.brightness == Brightness.dark;
    final metrics = workspaceProvider.dashboardMetrics;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStaff ? 'Staff Workspace' : 'Salon Workspace',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 2),
            Text(
              isStaff
                  ? 'My Schedule & Live Queue'
                  : 'Dashboard & Operations Queue',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              workspaceProvider.fetchDashboardMetrics();
              _pollBookings();
              AppFeedback.success(context, "Dashboard metrics updated live.");
            },
            tooltip: 'Refresh Metrics',
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _bookingsStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            );
          }

          final allSalonBookings = snapshot.data ?? [];

          final Map<String, Map<String, dynamic>> uniqueBookingsMap = {};
          for (var b in allSalonBookings) {
            final bId =
                b['id']?.toString() ??
                '${b['userId']}_${b['date']}_${b['timeSlot']}';
            if (!uniqueBookingsMap.containsKey(bId)) {
              uniqueBookingsMap[bId] = b;
            }
          }
          final cleanAllBookings = uniqueBookingsMap.values.toList();

          if (isStaff) {
            debugPrint(
              '[STAFF FILTER] id=${user?.id}, name=${user?.name}, email=${user?.email}',
            );
            if (cleanAllBookings.isNotEmpty) {
              final sample = cleanAllBookings.first;
              debugPrint(
                '[STAFF FILTER] Sample booking stylistId=${sample['stylistId']}, stylistName=${sample['stylistName']}',
              );
            }
          }
          final bookingsList = isStaff
              ? cleanAllBookings.where((b) {
                  final sId = (b['stylistId']?.toString() ?? '')
                      .trim()
                      .toLowerCase();
                  final sName = (b['stylistName']?.toString() ?? '')
                      .trim()
                      .toLowerCase();
                  final uId = (user?.id ?? '').trim().toLowerCase();
                  final uName = (user?.name ?? '').trim().toLowerCase();
                  final uEmail = (user?.email ?? '').trim().toLowerCase();
                  final uEmailPrefix = uEmail.contains('@')
                      ? uEmail.split('@')[0]
                      : '';

                  return sId == uId ||
                      sId == uEmail ||
                      (uEmailPrefix.isNotEmpty && sId == uEmailPrefix) ||
                      (uName.isNotEmpty && sName == uName) ||
                      (uName.isNotEmpty && sId == uName) ||
                      (uEmailPrefix.isNotEmpty && sName == uEmailPrefix) ||
                      sId == 'any_stylist' ||
                      sName == 'any_stylist';
                }).toList()
              : cleanAllBookings;

          bookingsList.sort(
            (a, b) =>
                b['createdAt'].toString().compareTo(a['createdAt'].toString()),
          );

          final activeQueue = bookingsList
              .where(
                (b) =>
                    b['status'] == 'in_queue' ||
                    b['status'] == 'confirmed' ||
                    b['status'] == 'pending',
              )
              .toList();
          final servingNow = bookingsList
              .where((b) => b['status'] == 'serving')
              .toList();
          final completed = bookingsList
              .where((b) => b['status'] == 'completed')
              .toList();

          activeQueue.sort((a, b) {
            final aDate = a['date'] as String? ?? '';
            final bDate = b['date'] as String? ?? '';
            int dateComp = aDate.compareTo(bDate);
            if (dateComp != 0) return dateComp;

            final aTime = _parseTimeSlot(a['timeSlot'] as String? ?? '');
            final bTime = _parseTimeSlot(b['timeSlot'] as String? ?? '');
            int timeComp = aTime.compareTo(bTime);
            if (timeComp != 0) return timeComp;

            return (a['queuePosition'] as int? ?? 0).compareTo(
              b['queuePosition'] as int? ?? 0,
            );
          });

          double dailyRevenue = 0.0;
          for (var b in completed) {
            dailyRevenue +=
                (b['servicePrice'] as num?)?.toDouble() ??
                (b['price'] as num?)?.toDouble() ??
                0.0;
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.25,
                        children: [
                          _buildMetricCard(
                            theme,
                            isDark,
                            label: "Today's Revenue",
                            value: "Rs. ${dailyRevenue.round()}",
                            badge: "${completed.length} completed",
                            badgeColor: Colors.white24,
                            isPinkGradient: true,
                            icon: Icons.payments_rounded,
                          ),
                          _buildMetricCard(
                            theme,
                            isDark,
                            label: "Appointments",
                            value: "${bookingsList.length}",
                            badge: "${activeQueue.length} in queue",
                            badgeColor: const Color(0xFFE8F5E9),
                            badgeTextColor: const Color(0xFF2E7D32),
                            isPinkGradient: false,
                            icon: Icons.calendar_month_rounded,
                          ),
                          _buildMetricCard(
                            theme,
                            isDark,
                            label: isStaff
                                ? "Active Stylist"
                                : "Salon Stylists",
                            value:
                                "${metrics?['staffCount'] ?? metrics?['content']?['stylists'] ?? 1}",
                            badge: isStaff ? "Assigned" : "Active Roster",
                            badgeColor: const Color(0xFFE8F5E9),
                            badgeTextColor: const Color(0xFF2E7D32),
                            isPinkGradient: false,
                            icon: Icons.people_outline_rounded,
                          ),
                          _buildMetricCard(
                            theme,
                            isDark,
                            label: "Active Services",
                            value: "${metrics?['content']?['services'] ?? 8}",
                            badge: "Live Menu",
                            badgeColor: const Color(0xFFE8F5E9),
                            badgeTextColor: const Color(0xFF2E7D32),
                            isPinkGradient: false,
                            icon: Icons.dry_cleaning_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(
                          isDark ? 30 : 60,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 0 : 4),
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
                            Text(
                              "Weekly Revenue",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          child: WeeklyRevenueChart(bookings: cleanAllBookings),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildSalesTargetsSection(
                  context,
                  theme,
                  isDark,
                  workspaceProvider,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Operations Manager",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        isStaff
                            ? "Track your assigned slots and bookings"
                            : "Real-time salon slot queue monitor board",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (servingNow.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Serving Now",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...servingNow.map(
                          (b) => _buildBookingCard(
                            context,
                            theme,
                            b,
                            isServing: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isStaff
                                ? "My Appointment Queue (${activeQueue.length})"
                                : "Waiting Queue (${activeQueue.length})",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              if (activeQueue.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.airline_seat_recline_extra_rounded,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Queue is clear",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final b = activeQueue[index];
                      return _buildBookingCard(
                        context,
                        theme,
                        b,
                        isServing: false,
                      );
                    }, childCount: activeQueue.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    bool isDark, {
    required String label,
    required String value,
    required String badge,
    required Color badgeColor,
    Color? badgeTextColor,
    required bool isPinkGradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isPinkGradient
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPinkGradient
            ? null
            : (isDark ? const Color(0xFF1E1C1B) : Colors.white),
        border: isPinkGradient
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withAlpha(isDark ? 30 : 60),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: isPinkGradient
                    ? Colors.white70
                    : theme.colorScheme.primary,
                size: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isPinkGradient
                        ? Colors.white
                        : (badgeTextColor ?? theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isPinkGradient
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isPinkGradient ? Colors.white70 : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> b, {
    required bool isServing,
  }) {
    final status = b['status'] as String;
    final pos = b['queuePosition'] as int? ?? 0;
    final isDark = theme.brightness == Brightness.dark;

    final isHomeService = b['isHomeService'] == true;
    final homeAddress = b['homeAddress']?.toString() ?? '';
    final contactNumber = b['contactNumber']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
        border: Border.all(
          color: isHomeService
              ? Colors.amber.withAlpha(isDark ? 100 : 180)
              : isServing
              ? Colors.blue.withAlpha(60)
              : theme.colorScheme.outline.withAlpha(isDark ? 30 : 60),
          width: isHomeService ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 0 : 3),
            blurRadius: 10,
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
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        b['userName'] ?? 'Customer',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isHomeService) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.shade700,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.home_work_rounded,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Home Service 🏠",
                              style: TextStyle(
                                color: Colors.amber.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isServing && status == 'in_queue')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(30),
                    ),
                  ),
                  child: Text(
                    "Pos #$pos",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (isServing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withAlpha(30)),
                  ),
                  child: const Text(
                    "Serving",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "${b['serviceName']}  ·  Rs. ${b['servicePrice']}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Stylist: ${b['stylistName']}   |   Slot: ${b['timeSlot']}",
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          if (isHomeService &&
              (homeAddress.isNotEmpty || contactNumber.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black38
                    : Colors.amber.shade50.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (homeAddress.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Address: $homeAddress",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (homeAddress.isNotEmpty && contactNumber.isNotEmpty)
                    const SizedBox(height: 4),
                  if (contactNumber.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Contact: $contactNumber",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (status == 'in_queue') ...[
                TextButton(
                  onPressed: () async {
                    final workspaceProv = context
                        .read<SalonWorkspaceProvider>();
                    final success = await workspaceProv.updateBookingStatus(
                      b['id'],
                      'cancelled',
                    );
                    if (context.mounted) {
                      if (success) {
                        AppFeedback.success(context, "Appointment cancelled.");
                      } else {
                        AppFeedback.error(
                          context,
                          workspaceProv.error ?? "Failed to cancel.",
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final workspaceProv = context
                        .read<SalonWorkspaceProvider>();
                    final success = await workspaceProv.updateBookingStatus(
                      b['id'],
                      'serving',
                    );
                    if (context.mounted) {
                      if (success) {
                        AppFeedback.success(context, "Serving client now.");
                      } else {
                        AppFeedback.error(
                          context,
                          workspaceProv.error ?? "Failed to start serving.",
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Start Serving",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else if (status == 'serving') ...[
                ElevatedButton(
                  onPressed: () async {
                    final workspaceProv = context
                        .read<SalonWorkspaceProvider>();
                    final success = await workspaceProv.updateBookingStatus(
                      b['id'],
                      'completed',
                    );
                    if (context.mounted) {
                      if (success) {
                        AppFeedback.success(
                          context,
                          "Service completed successfully!",
                        );
                      } else {
                        AppFeedback.error(
                          context,
                          workspaceProv.error ?? "Failed to complete service.",
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Complete",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static double _parseTimeSlot(String timeSlot) {
    try {
      final clean = timeSlot.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final parts = clean.substring(0, clean.length - 2).split(':');
      double hour = double.parse(parts[0]);
      final double minute = double.parse(parts[1]);
      final isPm = clean.endsWith('PM');

      if (isPm && hour != 12) {
        hour += 12;
      } else if (!isPm && hour == 12) {
        hour = 0;
      }

      return hour * 60 + minute;
    } catch (_) {
      return 0.0;
    }
  }

  Widget _buildSalesTargetsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    SalonWorkspaceProvider workspaceProvider,
  ) {
    final targets = workspaceProvider.targets;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(isDark ? 30 : 60),
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 0 : 4),
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
                Row(
                  children: [
                    const Icon(
                      Icons.ads_click_rounded,
                      color: Color(0xFFEC4899),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Sales Targets Tracker",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () =>
                      _showAddTargetDialog(context, workspaceProvider),
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Color(0xFFEC4899),
                  ),
                  label: const Text(
                    "Add Target",
                    style: TextStyle(
                      color: Color(0xFFEC4899),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (targets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 36,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "No sales targets defined yet",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _showAddTargetDialog(context, workspaceProvider),
                        child: const Text("Set Monthly Sales Target"),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: targets
                    .map(
                      (target) => _buildTargetCard(
                        context,
                        theme,
                        isDark,
                        target,
                        workspaceProvider,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    TargetModel target,
    SalonWorkspaceProvider workspaceProvider,
  ) {
    Color statusColor;
    String statusText;

    switch (target.status) {
      case 'exceeded':
        statusColor = const Color(0xFF10B981);
        statusText = 'Exceeded';
        break;
      case 'achieved':
        statusColor = const Color(0xFF059669);
        statusText = 'Achieved';
        break;
      case 'at_risk':
        statusColor = const Color(0xFFEF4444);
        statusText = 'At Risk';
        break;
      case 'on_track':
      default:
        statusColor = const Color(0xFF3B82F6);
        statusText = 'On Track';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161514) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  target.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Delete Target"),
                      content: const Text(
                        "Are you sure you want to delete this target?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await workspaceProvider.deleteTarget(target.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs. ${target.achievedRevenue.round()} of Rs. ${target.targetAmount.round()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                "${target.progressPercent}%",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (target.progressPercent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${target.daysRemaining} days left",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              if (target.requiredDailyRevenue > 0)
                Text(
                  "Req. Daily: Rs. ${target.requiredDailyRevenue.round()}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTargetDialog(
    BuildContext context,
    SalonWorkspaceProvider workspaceProvider,
  ) {
    final titleController = TextEditingController(text: "Monthly Sales Target");
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, 1);
    DateTime endDate = DateTime(now.year, now.month + 1, 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.ads_click_rounded, color: Color(0xFFEC4899)),
            SizedBox(width: 8),
            Text(
              "Set Sales Target",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Target Title"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Amount (Rs.)",
                  hintText: "e.g. 50000",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                AppFeedback.warning(ctx, "Please enter a valid target amount.");
                return;
              }
              Navigator.pop(ctx);
              final success = await workspaceProvider.createTarget(
                title: titleController.text.trim(),
                targetType: 'monthly',
                startDate: startDate.toIso8601String().split('T')[0],
                endDate: endDate.toIso8601String().split('T')[0],
                targetAmount: amount,
                notes: notesController.text.trim(),
              );
              if (ctx.mounted) {
                if (success) {
                  AppFeedback.success(
                    ctx,
                    "Sales target created successfully!",
                  );
                } else {
                  AppFeedback.error(
                    ctx,
                    workspaceProvider.error ?? "Failed to create target.",
                  );
                }
              }
            },
            child: const Text("Create Target"),
          ),
        ],
      ),
    );
  }
}

class WeeklyRevenueChart extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;

  const WeeklyRevenueChart({super.key, this.bookings = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Map<int, double> dailyTotals = {
      1: 0.0,
      2: 0.0,
      3: 0.0,
      4: 0.0,
      5: 0.0,
      6: 0.0,
      7: 0.0,
    };

    for (var b in bookings) {
      if (b['status'] == 'completed') {
        final dateStr = b['date'] as String? ?? '';
        try {
          final parsedDate = DateTime.parse(dateStr);
          final weekday = parsedDate.weekday;
          final price =
              (b['servicePrice'] as num?)?.toDouble() ??
              (b['price'] as num?)?.toDouble() ??
              0.0;
          dailyTotals[weekday] = (dailyTotals[weekday] ?? 0.0) + price;
        } catch (_) {}
      }
    }

    double maxRevenue = dailyTotals.values.fold(
      0.0,
      (prev, val) => val > prev ? val : prev,
    );
    if (maxRevenue == 0) maxRevenue = 1000.0;

    final List<double> liveValues = [
      (dailyTotals[1]! / maxRevenue).clamp(0.15, 1.0),
      (dailyTotals[2]! / maxRevenue).clamp(0.15, 1.0),
      (dailyTotals[3]! / maxRevenue).clamp(0.15, 1.0),
      (dailyTotals[4]! / maxRevenue).clamp(0.15, 1.0),
      (dailyTotals[5]! / maxRevenue).clamp(0.15, 1.0),
      (dailyTotals[6]! / maxRevenue).clamp(0.15, 1.0),
      (dailyTotals[7]! / maxRevenue).clamp(0.15, 1.0),
    ];

    final List<double> liveAmounts = [
      dailyTotals[1]!,
      dailyTotals[2]!,
      dailyTotals[3]!,
      dailyTotals[4]!,
      dailyTotals[5]!,
      dailyTotals[6]!,
      dailyTotals[7]!,
    ];

    int maxDayIndex = 0;
    double maxAmt = -1;
    for (int i = 0; i < liveAmounts.length; i++) {
      if (liveAmounts[i] > maxAmt) {
        maxAmt = liveAmounts[i];
        maxDayIndex = i;
      }
    }

    return CustomPaint(
      painter: _ChartPainter(
        lineColor: theme.colorScheme.primary,
        gridColor: theme.colorScheme.outline.withAlpha(isDark ? 20 : 40),
        textColor: Colors.grey.shade500,
        values: liveValues,
        amounts: liveAmounts,
        maxDayIndex: maxDayIndex,
      ),
      child: Container(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final List<double> values;
  final List<double> amounts;
  final int maxDayIndex;

  _ChartPainter({
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.values,
    required this.amounts,
    required this.maxDayIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPadding = 24.0;
    const double topPadding = 12.0;
    final double chartWidth = size.width;
    final double chartHeight = size.height - bottomPadding - topPadding;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final int gridLinesCount = 3;
    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = topPadding + (chartHeight / gridLinesCount) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final double stepX = chartWidth / (days.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final double x = stepX * i;
      final double y = topPadding + chartHeight * (1.0 - values[i]);
      points.add(Offset(x, y));
    }

    final pathBg = Path();
    pathBg.moveTo(points.first.dx, topPadding + chartHeight);
    pathBg.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      pathBg.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    pathBg.lineTo(points.last.dx, topPadding + chartHeight);
    pathBg.close();

    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withAlpha(60), lineColor.withAlpha(2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, topPadding, chartWidth, chartHeight));

    canvas.drawPath(pathBg, bgPaint);

    final pathLine = Path();
    pathLine.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      pathLine.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(pathLine, linePaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4.5, dotPaint);
      canvas.drawCircle(points[i], 4.5, dotBorderPaint);
    }

    for (int i = 0; i < days.length; i++) {
      final textSpan = TextSpan(
        text: days[i],
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double x = stepX * i - (textPainter.width / 2);
      final double y = size.height - bottomPadding + 6;
      textPainter.paint(canvas, Offset(x, y));
    }

    final Offset tooltipPoint = points[maxDayIndex];
    final double maxRevenue = amounts[maxDayIndex];
    final String formattedText = maxRevenue >= 1000
        ? "Rs. ${(maxRevenue / 1000).toStringAsFixed(1)}K"
        : "Rs. ${maxRevenue.round()}";

    final rect = Rect.fromLTWH(
      tooltipPoint.dx - 34,
      tooltipPoint.dy - 38,
      68,
      26,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    final tooltipBgPaint = Paint()..color = lineColor;
    canvas.drawRRect(rrect, tooltipBgPaint);

    final arrowPath = Path()
      ..moveTo(tooltipPoint.dx - 5, tooltipPoint.dy - 12)
      ..lineTo(tooltipPoint.dx, tooltipPoint.dy - 6)
      ..lineTo(tooltipPoint.dx + 5, tooltipPoint.dy - 12)
      ..close();
    canvas.drawPath(arrowPath, tooltipBgPaint);

    final tooltipSpan = TextSpan(
      text: formattedText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
    final tooltipPainter = TextPainter(
      text: tooltipSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    tooltipPainter.paint(
      canvas,
      Offset(
        tooltipPoint.dx - (tooltipPainter.width / 2),
        tooltipPoint.dy - 31,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
