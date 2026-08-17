import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/shared/design_system/sv_button.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _msgController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await AppService.instance.createSupportTicket(
      _subjectController.text.trim(),
      _msgController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (res is Success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support ticket submitted! We will respond promptly.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((res as Failure).message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Submit Support Ticket',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g. Booking reschedule issue',
                    prefixIcon: Icon(Icons.topic_outlined),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a subject' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _msgController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Message / Description',
                    hintText: 'Provide details about your question or issue...',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 90),
                      child: Icon(Icons.chat_outlined),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please describe your query' : null,
                ),
                const SizedBox(height: 32),

                SVButton(
                  text: 'Submit Support Ticket',
                  isFullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
