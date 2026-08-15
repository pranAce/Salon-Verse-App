import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_filex/open_filex.dart';
import 'package:salonverse/widgets/feedback_helper.dart';

class ReceiptPdfHelper {
  static Future<void> generateAndDownloadReceipt({
    required BuildContext context,
    required dynamic booking,
  }) async {
    try {
      final pdf = pw.Document();

      final String bookingId = booking.id is String
          ? booking.id
          : "BK-${DateTime.now().millisecondsSinceEpoch}";
      final String salonName = booking.salonName ?? "SalonVerse Partner Salon";
      final String serviceName = booking.serviceName ?? "Salon Service";
      final String stylistName = booking.stylistName ?? "Assigned Stylist";
      final String date = booking.date ?? "2026-08-15";
      final String timeSlot = booking.timeSlot ?? "10:00 AM";
      final String paymentMethod = (booking.paymentMethod ?? "Pay at Salon")
          .toString()
          .toUpperCase();
      final double price = (booking.servicePrice as num?)?.toDouble() ?? 500.0;
      final String pStatus =
          booking.paymentStatus?.toString().toLowerCase() ?? '';
      final bool isPaid = pStatus == 'completed' || pStatus == 'paid';
      final String txnId =
          "TXN-${bookingId.length >= 6 ? bookingId.substring(0, 6).toUpperCase() : bookingId.toUpperCase()}-$paymentMethod";

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "SALONVERSE",
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex("#EC4899"),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Official Appointment Receipt & Invoice",
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: isPaid
                            ? PdfColor.fromHex("#DEF7EC")
                            : PdfColor.fromHex("#FEF08A"),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        isPaid ? "PAID IN FULL" : "PAYMENT PENDING",
                        style: pw.TextStyle(
                          color: isPaid
                              ? PdfColor.fromHex("#03543F")
                              : PdfColor.fromHex("#713F12"),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColor.fromHex("#E5E7EB"), thickness: 1.2),
                pw.SizedBox(height: 16),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "RECEIPT FOR:",
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          booking.userName ?? "Customer",
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Kathmandu, Nepal",
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "INVOICE NO: $txnId",
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          "Booking ID: $bookingId",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          "Issued: ${DateTime.now().toString().split('.').first}",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex("#E5E7EB")),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        color: PdfColor.fromHex("#F9FAFB"),
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 4,
                              child: pw.Text(
                                "Service & Salon Details",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                "Date / Time",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "Stylist",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "Amount",
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Divider(height: 1, color: PdfColor.fromHex("#E5E7EB")),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 4,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    serviceName,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    salonName,
                                    style: const pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                "$date\n$timeSlot",
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                stylistName,
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "Rs. ${price.round()}",
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 240,
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Service Total:",
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                "Rs. ${price.round()}",
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Platform & Booking Fee:",
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                "Rs. 0 (Waived)",
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.green700,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Divider(color: PdfColor.fromHex("#E5E7EB")),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Total Amount:",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              pw.Text(
                                "Rs. ${price.round()}",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                  color: PdfColor.fromHex("#EC4899"),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Payment Method:",
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.Text(
                                paymentMethod,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),

                pw.Divider(color: PdfColor.fromHex("#E5E7EB")),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Thank you for choosing SalonVerse!",
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "Support: support@salonverse.live",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      final outputDir = await getApplicationDocumentsDirectory();
      final sanitizedId = bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File(
        "${outputDir.path}/SalonVerse_Receipt_$sanitizedId.pdf",
      );
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        AppFeedback.success(context, "Receipt PDF saved to ${file.path}");
      }

      try {
        await OpenFilex.open(file.path);
      } catch (_) {
        await Printing.sharePdf(
          bytes: bytes,
          filename: "SalonVerse_Receipt_$sanitizedId.pdf",
        );
      }
    } catch (e) {
      debugPrint("Error generating PDF receipt: $e");
      if (context.mounted) {
        AppFeedback.error(context, "Could not generate PDF: $e");
      }
    }
  }
}
