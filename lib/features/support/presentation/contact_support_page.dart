import 'package:flutter/material.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/widgets/app_button.dart';
import 'package:salonverse/core/widgets/app_text_field.dart';
import 'package:salonverse/core/widgets/feedback_helper.dart';

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

    setState(() {
      _isLoading = true;
    });

    final res = await AppService.instance.createSupportTicket(
      _subjectController.text.trim(),
      _msgController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (res is Success) {
        AppFeedback.success(context, "Support ticket created successfully!");
        Navigator.pop(context);
      } else {
        AppFeedback.error(context, (res as Failure).message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  AppTextField(
                    controller: _subjectController,
                    label: "Subject",
                    prefixIcon: Icons.topic_outlined,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please enter a subject.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _msgController,
                    label: "Describe your query or issue",
                    prefixIcon: Icons.message_outlined,
                    maxLines: 6,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please describe your query.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    label: "Submit Ticket",
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
