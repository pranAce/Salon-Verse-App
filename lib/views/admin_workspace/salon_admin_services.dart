import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_provider.dart';
import 'package:salonverse/models/salon_model.dart';

class SalonAdminServices extends StatefulWidget {
  const SalonAdminServices({super.key});

  @override
  State<SalonAdminServices> createState() => _SalonAdminServicesState();
}

class _SalonAdminServicesState extends State<SalonAdminServices> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalonProvider>().fetchSalons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final salonId = user?.salonId ?? '';
    final salonProvider = context.watch<SalonProvider>();

    // 1. Find assigned salon or collect all services across active salons
    SalonModel? matchedSalon;
    if (salonId.isNotEmpty && salonProvider.salons.isNotEmpty) {
      try {
        matchedSalon = salonProvider.salons.firstWhere((s) => s.id == salonId);
      } catch (_) {}
    }

    // Fallback: If salonId didn't match, pick the first available salon or flatten all services
    final List<ServiceModel> services = matchedSalon != null && matchedSalon.services.isNotEmpty
        ? matchedSalon.services
        : salonProvider.salons.expand((s) => s.services).toList();

    final salonName = matchedSalon?.name ?? (salonProvider.salons.isNotEmpty ? salonProvider.salons.first.name : "SalonVerse");

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Services Directory",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Active service menu for $salonName",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          if (salonProvider.isLoading && services.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (services.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dry_cleaning_rounded, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No services listed yet.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final s = services[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 30 : 60)),
                      ),
                      child: Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.spa_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text("${s.durationMinutes} mins · ${s.category}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Text("Rs. ${s.price.round()}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: theme.colorScheme.primary)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  s.description.isNotEmpty ? s.description : 'No description provided.',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: services.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
