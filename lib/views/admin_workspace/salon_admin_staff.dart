import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_workspace_provider.dart';
import 'package:salonverse/models/staff_model.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class SalonAdminStaff extends StatefulWidget {
  const SalonAdminStaff({super.key});

  @override
  State<SalonAdminStaff> createState() => _SalonAdminStaffState();
}

class _SalonAdminStaffState extends State<SalonAdminStaff> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<AuthProvider>().currentUser;
      final salonId = user?.salonId ?? '';
      await context.read<SalonWorkspaceProvider>().fetchStaff(salonId);
      if (mounted && context.read<SalonWorkspaceProvider>().staffList.isEmpty) {
        context.read<SalonWorkspaceProvider>().fetchStaff('');
      }
    });
  }

  Future<void> _toggleAvailability(
    BuildContext context,
    String salonId,
    StaffModel staff,
  ) async {
    final workspaceProvider = Provider.of<SalonWorkspaceProvider>(
      context,
      listen: false,
    );
    final newStatus = staff.isActive ? 'disabled' : 'active';

    try {
      final success = await workspaceProvider.updateStaff(
        salonId: salonId,
        staffId: staff.id,
        status: newStatus,
      );

      if (context.mounted) {
        if (success) {
          AppFeedback.success(
            context,
            "${staff.name} is now ${newStatus == 'active' ? 'Available' : 'Away'}.",
          );
        } else {
          AppFeedback.error(
            context,
            workspaceProvider.error ?? "Failed to update availability.",
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.error(context, "Failed to update availability: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final salonId = user?.salonId ?? 'salon_1';
    final isStaff = user?.isSalonStaff == true;
    final workspaceProvider = context.watch<SalonWorkspaceProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stylist Roster",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Active salon staff listings",
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                workspaceProvider.isLoading &&
                    workspaceProvider.staffList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : workspaceProvider.staffList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No staff registered yet.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: workspaceProvider.staffList.length,
                    itemBuilder: (context, index) {
                      final s = workspaceProvider.staffList[index];
                      final canToggle =
                          !isStaff ||
                          (isStaff &&
                              (s.id == user?.id ||
                                  s.email.toLowerCase() ==
                                      user?.email.toLowerCase()));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161514)
                              : Colors.white,
                          border: Border.all(
                            color: theme.colorScheme.outline.withAlpha(
                              isDark ? 30 : 60,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 10 : 5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: theme.colorScheme.primary
                                  .withAlpha(15),
                              child: Text(
                                s.name.isNotEmpty
                                    ? s.name[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.email,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (s.number != null &&
                                      s.number!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      s.number!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (canToggle) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Switch.adaptive(
                                    value: s.isActive,
                                    activeTrackColor: Colors.green,
                                    onChanged: (_) => _toggleAvailability(
                                      context,
                                      salonId,
                                      s,
                                    ),
                                  ),
                                  Text(
                                    s.isActive ? "Available" : "Away",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: s.isActive
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: s.isActive
                                      ? Colors.green.withAlpha(15)
                                      : Colors.grey.withAlpha(15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: s.isActive
                                        ? Colors.green.withAlpha(40)
                                        : Colors.grey.withAlpha(40),
                                  ),
                                ),
                                child: Text(
                                  s.isActive ? "Available" : "Away",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: s.isActive
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
