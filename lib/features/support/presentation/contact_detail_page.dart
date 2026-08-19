import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/support/services/support_service.dart';
import 'package:salonverse/features/auth/services/auth_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/features/support/models/support_ticket_model.dart';

class ContactDetailPage extends StatefulWidget {
  final String ticketId;
  final String subject;

  const ContactDetailPage({
    super.key,
    required this.ticketId,
    required this.subject,
  });

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final TextEditingController _msgController = TextEditingController();
  SupportTicketModel? _ticket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicketDetail();
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketDetail() async {
    final res = await SupportService().getSupportTickets(
      AuthService().currentUser,
    );
    if (res is Success<List<SupportTicketModel>>) {
      SupportTicketModel? match;
      try {
        match = res.data.firstWhere((t) => t.id == widget.ticketId);
      } catch (_) {}
      setState(() {
        _ticket = match;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSend() async {
    if (_msgController.text.trim().isEmpty) return;

    final text = _msgController.text.trim();
    _msgController.clear();

    final res = await SupportService().replyToTicket(widget.ticketId, text);
    if (res is Success<SupportTicketModel>) {
      setState(() => _ticket = res.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _ticket == null
            ? const Center(child: Text('Ticket details could not be loaded.'))
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildChatBubble(
                          sender: 'user',
                          message: _ticket!.message,
                          sentAt: _ticket!.createdAt,
                          isInitial: true,
                          isDark: isDark,
                        ),
                        ..._ticket!.messages.map(
                          (msg) => _buildChatBubble(
                            sender: msg.sender,
                            message: msg.message,
                            sentAt: msg.sentAt,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceElevated
                                  : AppColors.lightSurfaceSecondary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _msgController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _handleSend,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildChatBubble({
    required String sender,
    required String message,
    required String sentAt,
    required bool isDark,
    bool isInitial = false,
  }) {
    final isMe = sender == 'user';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceSecondary),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: isMe
              ? AppSpacing.glowShadow(AppColors.primary, opacity: 0.2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isInitial) ...[
              Text(
                'Original Request:',
                style: GoogleFonts.plusJakartaSans(
                  color: isMe ? Colors.white70 : AppColors.primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: isMe
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
