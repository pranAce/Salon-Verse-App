import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/views/salon/booking_widgets/booking_step1_services.dart';
import 'package:salonverse/views/salon/booking_widgets/booking_step2_schedule_payment.dart';
import 'package:salonverse/views/salon/booking_widgets/booking_bottom_bar.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    if (bookingProvider.selectedSalon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment'), elevation: 0),
        body: const Center(child: Text('No active booking details found.')),
      );
    }

    final salon = bookingProvider.selectedSalon!;
    final selectedService = bookingProvider.selectedService;
    final selectedStylist = bookingProvider.selectedStylist;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090808) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF090808) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() {
                _currentStep = 0;
              });
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              _currentStep == 0
                  ? "Select Service & Stylist"
                  : "Select Schedule & Payment",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepperProgress(isDark),

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
                setState(() {
                  _currentStep = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperProgress(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090808) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _stepNode(0, "Services", _currentStep >= 0, isDark),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: _currentStep >= 1
                  ? const Color(0xFFEC4899)
                  : (isDark ? const Color(0xFF2C2A29) : Colors.grey.shade200),
            ),
          ),
          _stepNode(1, "Schedule", _currentStep >= 1, isDark),
        ],
      ),
    );
  }

  Widget _stepNode(int index, String label, bool isActive, bool isDark) {
    const activeColor = Color(0xFFEC4899);
    final inactiveColor = isDark
        ? const Color(0xFF2C2A29)
        : Colors.grey.shade200;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "${index + 1}",
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.grey),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.white38 : Colors.grey),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
