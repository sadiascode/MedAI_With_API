import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/prescription_model.dart';
import '../models/prescription_medicine_model.dart';

class PrescriptionPdfService {
  static Future<bool> generateAndSavePrescriptionPdf(PrescriptionModel prescription) async {
    try {
      final pdf = pw.Document();
      Directory directory;
      String fileName = 'prescription_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (Platform.isAndroid) {
        directory = await _getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath = '${directory.path}/$fileName';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MED AI',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'PRESCRIPTION',
                  style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1565C0')),
                ),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 12),

                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E3F2FD'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Patient Information',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Name: ${prescription.patient.name}'),
                          pw.Text('Age: ${prescription.patient.age}'),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Health Issues: ${prescription.patient.healthIssues}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                if (prescription.medicines.isNotEmpty)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Prescription Details',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300),
                        children: prescription.medicines.map((med) {
                          return pw.TableRow(children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(med.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text('${med.howManyDay} days')),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: _buildMedicineTimes(med),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ],
                  ),
                pw.SizedBox(height: 16),

                if (prescription.medicalTests.isNotEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color:  PdfColor.fromHex('#E3F2FD'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Medical Tests',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 6),
                        ...prescription.medicalTests.map((test) => pw.Bullet(text: test.testName)),
                      ],
                    ),
                  ),
                pw.SizedBox(height: 16),

                if (prescription.nextAppointmentDate != null)
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color:  PdfColor.fromHex('#E3F2FD'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                    ),
                    child: pw.Text(
                      'Next Follow-up: ${_formatNextAppointment(prescription.nextAppointmentDate)}',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,),
                    ),
                  ),
                pw.Spacer(),

                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generated: ${_formatDate(DateTime.now())}',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.Text('Care Agent App',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (Platform.isIOS) {
        await Share.shareXFiles([XFile(filePath)], text: 'Prescription PDF');
      }

      return true;
    } catch (e) {
      print(' Error generating PDF: $e');
      throw Exception('Failed to generate prescription PDF: $e');
    }
  }

  static Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      try {
        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final String downloadsPath = '${externalDir.path.split('Android')[0]}Download';
          final Directory downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) await downloadsDir.create(recursive: true);
          return downloadsDir;
        }
      } catch (e) {
        print(' Could not access Downloads directory: $e');
      }
    }
    return null;
  }

  static String _formatNextAppointment(String? date) {
    if (date == null) return 'Not scheduled';
    try {
      final d = DateTime.tryParse(date);
      if (d != null) return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
    } catch (_) {}
    return date;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }

  static pw.Widget _buildMedicineTimes(PrescriptionMedicineModel medicine) {
    final List<pw.Widget> times = [];
    if (medicine.hasMorning) times.add(_timeSlot("Morning", medicine.morningDisplay, PdfColors.yellow200));
    if (medicine.hasAfternoon) times.add(_timeSlot("Afternoon", medicine.afternoonDisplay, PdfColors.orange200));
    if (medicine.hasEvening) times.add(_timeSlot("Evening", medicine.eveningDisplay, PdfColors.purple200));
    if (medicine.hasNight) times.add(_timeSlot("Night", medicine.nightDisplay, PdfColors.blue200));

    return pw.Wrap(
      spacing: 4,
      runSpacing: 4,
      children: times,
    );
  }

  static pw.Widget _timeSlot(String label, String time, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text("$label: $time", style: const pw.TextStyle(fontSize: 10)),
    );
  }
}
