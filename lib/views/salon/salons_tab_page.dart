import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/views/admin_workspace/salon_admin_dashboard.dart';
import 'package:salonverse/views/salon/salons_directory_page.dart';

class SalonsTabPage extends StatelessWidget {
  const SalonsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isSalonRole = user?.isSalonRole ?? false;

    if (isSalonRole) {
      return const SalonAdminDashboard();
    } else {
      return const SalonsDirectoryPage();
    }
  }
}
