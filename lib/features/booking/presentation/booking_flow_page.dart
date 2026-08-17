import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/shared/design_system/sv_selection_widgets.dart';
import 'package:salonverse/shared/design_system/sv_feedback_states.dart';
import 'package:salonverse/features/booking/presentation/booking_widgets/booking_step1_services.dart';
import 'package:salonverse/features/booking/presentation/booking_widgets/booking_step2_schedule_payment.dart';
import 'package:salonverse/features/booking/presentation/booking_widgets/booking_bottom_bar.dart';

class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({super.key});

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BookingProvider>();
    if (provider.selectedService != null) {
      _currentStep = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchDynamicSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    if (bookingProvider.selectedSalon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const SVEmptyState(
          icon: Icons.calendar_today_rounded,
          title: 'No Active Booking',
          description: 'Please select a salon and service first.',
        ),
      );
    }

    final salon = bookingProvider.selectedSalon!;
    final selectedService = bookingProvider.selectedService;
    final selectedStylist = bookingProvider.selectedStylist;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              salon.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              _currentStep == 0 ? 'Select Service & Stylist' : 'Schedule & Payment',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SVStepIndicator(
              currentStep: _currentStep,
              steps: const ['Service & Specialist', 'Schedule & Pay'],
              onStepTapped: (index) {
                if (index == 1 && selectedService == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a service first.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  return;
                }
                setState(() => _currentStep = index);
              },
            ),

            Expanded(
              child: _currentStep == 0
                  ? BookingStep1Services(
                      salon: salon,
                      selectedService: selectedService,
                      selectedStylist: selectedStylist,
                    )
                  : BookingStep2SchedulePayment(
                      salon: salon,
                      service: selectedService,
                      stylist: selectedStylist,
                    ),
            ),

            BookingBottomBar(
              currentStep: _currentStep,
              selectedService: selectedService,
              selectedStylist: selectedStylist,
              provider: bookingProvider,
              onContinueToStep2: () {
                setState(() => _currentStep = 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
