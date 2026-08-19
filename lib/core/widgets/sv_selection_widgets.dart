import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/booking/models/booking_slot_model.dart';

class SVSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SVSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SVSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool readOnly;
  final bool hasActiveFilter;
  final VoidCallback? onTap;

  const SVSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search salons, services, stylists...',
    this.onChanged,
    this.onFilterTap,
    this.onClear,
    this.autofocus = false,
    this.readOnly = false,
    this.hasActiveFilter = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.primary.withAlpha(40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(50)
                : AppColors.primary.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
          if (controller != null &&
              controller!.text.isNotEmpty &&
              onClear != null)
            GestureDetector(
              onTap: () {
                controller!.clear();
                onClear!();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          if (onFilterTap != null) ...[
            Container(
              height: 24,
              width: 1,
              color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            GestureDetector(
              onTap: onFilterTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: hasActiveFilter
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.primaryTint),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: hasActiveFilter
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ] else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class SVCFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const SVCFilterChip({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFA060C0), Color(0xFFC060C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA060C0).withAlpha(90),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 6),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SVStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final ValueChanged<int>? onStepTapped;

  const SVStepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: onStepTapped != null ? () => onStepTapped!(index) : null,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.lightSurfaceSecondary),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? Colors.white
                                    : (isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.lightTextTertiary),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      steps[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isCurrent
                            ? (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary)
                            : (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary),
                      ),
                    ),
                  ),
                  if (index < steps.length - 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 1.5,
                      color: isCompleted
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class SVDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const SVDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SVDateScroller(
      selectedDate: selectedDate,
      onDateSelected: onDateSelected,
    );
  }
}

class SVTimeSlotSelector extends StatelessWidget {
  final List<dynamic> availableSlots;
  final List<dynamic> bookedSlots;
  final String? selectedSlot;
  final bool isLoading;
  final bool isSalonClosed;
  final String? closureReason;
  final ValueChanged<String> onSlotSelected;

  const SVTimeSlotSelector({
    super.key,
    required this.availableSlots,
    this.bookedSlots = const [],
    this.selectedSlot,
    this.isLoading = false,
    this.isSalonClosed = false,
    this.closureReason,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (isSalonClosed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.error.withAlpha(40)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                closureReason != null && closureReason!.isNotEmpty
                    ? closureReason!
                    : 'Salon is closed on this date.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final slots = availableSlots
        .map((s) => s is BookingSlotModel ? s.timeSlot : s.toString())
        .toList();

    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_busy_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No appointments available for this date. Please select another date.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final isBooked = bookedSlots.contains(slot);
        final isSelected = selectedSlot == slot;

        return GestureDetector(
          onTap: isBooked ? null : () => onSlotSelected(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isBooked
                  ? (isDark ? Colors.white10 : Colors.grey.shade200)
                  : (isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceSecondary),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isBooked
                    ? Colors.transparent
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Text(
              slot,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isBooked
                    ? (isDark ? Colors.white30 : Colors.grey.shade400)
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SVDateScroller extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysCount;

  const SVDateScroller({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysCount = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();

    final weekdayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysCount,
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index));
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final dayName = weekdayNames[date.weekday - 1];
          final monthName = monthNames[date.month - 1];

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                boxShadow: isSelected ? AppSpacing.softShadow(context) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white.withAlpha(210)
                          : (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                    ),
                  ),
                  Text(
                    monthName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withAlpha(210)
                          : (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
