import 'package:flutter/material.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/features/support/models/support_ticket_model.dart';
import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/core/widgets/feedback_helper.dart';

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
    final res = await AppService.instance.getSupportTickets();
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSend() async {
    if (_msgController.text.trim().isEmpty) return;

    final text = _msgController.text.trim();
    _msgController.clear();

    final res = await AppService.instance.replyToTicket(widget.ticketId, text);
    if (res is Success<SupportTicketModel>) {
      setState(() {
        _ticket = res.data;
      });
    } else {
      if (mounted) {
        AppFeedback.error(context, (res as Failure).message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.subject)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _ticket == null
            ? const Center(child: Text("Ticket details could not be loaded."))
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
                        ),

                        ..._ticket!.messages.map(
                          (msg) => _buildChatBubble(
                            sender: msg.sender,
                            message: msg.message,
                            sentAt: msg.sentAt,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withAlpha(80),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.darkSurfaceElevated
                                  : AppColors.lightSurfaceSecondary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _msgController,
                              decoration: const InputDecoration(
                                hintText: "Type your reply...",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _handleSend,
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
    bool isInitial = false,
  }) {
    final theme = Theme.of(context);
    final isMe = sender == 'user';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.brightness == Brightness.dark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceSecondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isInitial)
              Text(
                'Original Request:',
                style: TextStyle(
                  color: isMe ? Colors.white70 : theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isInitial) const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
