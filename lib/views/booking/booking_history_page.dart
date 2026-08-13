import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/models/booking_model.dart';
import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/widgets/shimmer_loading.dart';
import 'package:salonverse/widgets/empty_state.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Bookings',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your appointments in one place',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, size: 20),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C1B) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: theme.colorScheme.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                  Tab(text: "Cancelled"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ShimmerLoading(
          isLoading: bookingProvider.isLoading,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(context, bookingProvider, ['pending', 'confirmed', 'in_queue', 'in_service', 'serving']),
              _buildList(context, bookingProvider, ['completed']),
              _buildList(context, bookingProvider, ['cancelled', 'no_show']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, BookingProvider provider, List<String> statuses) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Map<String, BookingModel> uniqueMap = {};
    for (var b in provider.bookings) {
      final statusLower = b.status.toLowerCase();
      if (statuses.contains(statusLower) && !uniqueMap.containsKey(b.id)) {
        uniqueMap[b.id] = b;
      }
    }
    final filtered = uniqueMap.values.toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_rounded,
        title: 'No bookings found',
        subtitle: 'No appointments under this tab currently.',
        actionLabel: (statuses.contains('confirmed') || statuses.contains('in_queue')) ? 'Book a Session' : null,
        onAction: (statuses.contains('confirmed') || statuses.contains('in_queue')) ? () => context.go('/home') : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: filtered.length,
      itemBuilder: (context, idx) {
        final booking = filtered[idx];
        final statusLower = booking.status.toLowerCase();

        Color statusBg = const Color(0xFFEC4899).withAlpha(15);
        Color statusText = const Color(0xFFEC4899);
        String statusLabel = "CONFIRMED";

        if (statusLower == 'in_service' || statusLower == 'serving') {
          statusBg = Colors.blue.withAlpha(20);
          statusText = Colors.blue.shade700;
          statusLabel = "IN SERVICE";
        } else if (statusLower == 'completed') {
          statusBg = Colors.green.withAlpha(20);
          statusText = Colors.green.shade700;
          statusLabel = "COMPLETED";
        } else if (statusLower == 'cancelled' || statusLower == 'no_show') {
          statusBg = Colors.red.withAlpha(20);
          statusText = Colors.red.shade700;
          statusLabel = statusLower == 'no_show' ? "NO SHOW" : "CANCELLED";
        } else if (statusLower == 'pending') {
          statusBg = Colors.orange.withAlpha(20);
          statusText = Colors.orange.shade800;
          statusLabel = "PENDING";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(isDark ? 30 : 60),
            ),
            borderRadius: BorderRadius.circular(24),
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
            children: [
              // Header Card Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: booking.salonImageUrl.isNotEmpty
                          ? booking.salonImageUrl
                          : "https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=400&q=80",
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusText.withAlpha(40)),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: statusText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          booking.salonName,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.grey, size: 12),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                booking.salonAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),

              // Detail brief
              Text(
                "${booking.serviceName} with ${booking.stylistName}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Date/Time pill boxes wrapped safely
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFFEC4899)),
                        const SizedBox(width: 6),
                        Text(
                          booking.date,
                          style: const TextStyle(
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFEC4899)),
                        const SizedBox(width: 6),
                        Text(
                          booking.timeSlot,
                          style: const TextStyle(
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 28),

              // Actions Row
              Row(
                children: [
                  if (statusLower != 'completed' && statusLower != 'cancelled' && statusLower != 'no_show') ...[
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEC4899),
                            backgroundColor: const Color(0xFFEC4899).withAlpha(12),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            AppFeedback.success(context, "Reschedule request initiated.");
                          },
                          child: const Text("Reschedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEC4899),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.push('/payment-confirmation');
                          },
                          child: const Text("View Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ),
                  ] else if (statusLower == 'completed') ...[
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            AppFeedback.success(context, "Receipt PDF downloaded!");
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded, size: 14),
                              SizedBox(width: 4),
                              Text("Receipt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: booking.reviewed ? Colors.grey : theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: booking.reviewed
                              ? null
                              : () => _showReviewBottomSheet(context, booking),
                          child: Text(
                            booking.reviewed ? "Reviewed" : "Rate & Review",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Cancelled booking card details
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "This appointment was cancelled.",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReviewBottomSheet(BuildContext context, BookingModel booking) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double salonRating = 5.0;
    double stylistRating = 5.0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C1B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 30 : 65)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(60),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Review Experience",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Rate your service at ${booking.salonName}",
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    
                    // Salon Rating
                    const Text(
                      "How was the salon service?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return IconButton(
                          onPressed: () {
                            setModalState(() {
                              salonRating = starValue;
                            });
                          },
                          icon: Icon(
                            salonRating >= starValue ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Stylist Rating
                    Text(
                      "Rate stylist ${booking.stylistName}?",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return IconButton(
                          onPressed: () {
                            setModalState(() {
                              stylistRating = starValue;
                            });
                          },
                          icon: Icon(
                            stylistRating >= starValue ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Review Comment Input
                    const Text(
                      "Your review",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText: "Tell others about the salon and stylist...",
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        fillColor: isDark ? const Color(0xFF161514) : Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setModalState(() {
                                  isSubmitting = true;
                                });
                                
                                try {
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  if (context.mounted) {
                                    Navigator.pop(context); // Close bottom sheet
                                    AppFeedback.success(context, "Thank you! Your review has been saved.");
                                    context.read<BookingProvider>().fetchBookings();
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    isSubmitting = false;
                                  });
                                  if (context.mounted) {
                                    AppFeedback.error(context, "Failed to submit review: $e");
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Submit Review", style: TextStyle(fontWeight: FontWeight.bold)),
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
}
