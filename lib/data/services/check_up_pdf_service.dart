import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/models/check_up.dart';
import '../../domain/models/check_up_analysis.dart';

class CheckUpReportData {
  final CheckUpAnalysis analysis;
  final CycleContextSnapshot cycleContext;
  final CheckUp? checkUp;
  final DateTime generatedAt;

  CheckUpReportData({
    required this.analysis,
    required this.cycleContext,
    required this.checkUp,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  String get fileName {
    final date = checkUp?.date ?? generatedAt;
    final stamp =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return 'heralth-check-up-$stamp.pdf';
  }
}

abstract interface class CheckUpReportExporter {
  Future<void> share(CheckUpReportData report);
  Future<String?> download(CheckUpReportData report);
}

class DeviceCheckUpReportExporter implements CheckUpReportExporter {
  final CheckUpPdfService _pdfService;

  DeviceCheckUpReportExporter({CheckUpPdfService? pdfService})
    : _pdfService = pdfService ?? CheckUpPdfService();

  @override
  Future<void> share(CheckUpReportData report) async {
    final bytes = await _pdfService.generate(report);
    await Printing.sharePdf(bytes: bytes, filename: report.fileName);
  }

  @override
  Future<String?> download(CheckUpReportData report) async {
    final bytes = await _pdfService.generate(report);
    return FilePicker.platform.saveFile(
      dialogTitle: 'Save HerAlth check-up report',
      fileName: report.fileName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      bytes: bytes,
    );
  }
}

class CheckUpPdfService {
  Future<Uint8List> generate(CheckUpReportData report) async {
    final document = pw.Document(
      title: 'HerAlth Check-up Report',
      author: 'HerAlth',
      subject: 'Private informational check-up report',
    );
    final rose = PdfColor.fromHex('#9E385A');
    final palePink = PdfColor.fromHex('#FCF0F0');
    final ink = PdfColor.fromHex('#2C2C2C');
    final muted = PdfColor.fromHex('#6E6E6E');
    final divider = PdfColor.fromHex('#E5D9D9');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'HerAlth',
              style: pw.TextStyle(
                color: rose,
                fontSize: 19,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'PRIVATE CHECK-UP REPORT',
              style: pw.TextStyle(
                color: muted,
                fontSize: 9,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated locally by HerAlth',
              style: pw.TextStyle(color: muted, fontSize: 8),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(color: muted, fontSize: 8),
            ),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 26),
          pw.Text(
            report.analysis.headline,
            style: pw.TextStyle(
              color: ink,
              fontSize: 25,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Check-up date: ${_formatDate(report.checkUp?.date ?? report.generatedAt)}',
            style: pw.TextStyle(color: muted, fontSize: 10),
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: palePink,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  report.analysis.attention.toUpperCase(),
                  style: pw.TextStyle(
                    color: rose,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  report.analysis.summary,
                  style: pw.TextStyle(color: ink, fontSize: 12, lineSpacing: 3),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Signal strength: ${report.analysis.signalStrength} (${report.analysis.signalPercent}%)',
                  style: pw.TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          if (report.checkUp != null) ...[
            _sectionTitle('REPORTED INPUTS', rose),
            _card(divider, [
              _labelValue(
                'Symptoms',
                report.checkUp!.symptoms.isEmpty
                    ? 'None reported'
                    : report.checkUp!.symptoms
                          .map((symptom) => symptom.name)
                          .join(', '),
                ink,
                muted,
              ),
              if (report.checkUp!.notes.trim().isNotEmpty)
                _labelValue(
                  'Additional notes',
                  report.checkUp!.notes.trim(),
                  ink,
                  muted,
                ),
              _labelValue(
                'Ultrasound',
                report.checkUp!.ultrasoundPath == null
                    ? 'Not attached'
                    : 'Attached and validated for this analysis',
                ink,
                muted,
              ),
            ]),
          ],
          _sectionTitle('WHAT HERALTH OBSERVED', rose),
          _card(
            divider,
            report.analysis.observedSignals.isEmpty
                ? [pw.Text('No specific signals were returned.')]
                : report.analysis.observedSignals
                      .map(
                        (signal) =>
                            _listItem(signal.title, signal.detail, ink, muted),
                      )
                      .toList(),
          ),
          _sectionTitle('POSSIBLE EXPLANATIONS', rose),
          _card(
            divider,
            report.analysis.possibleExplanations.isEmpty
                ? [pw.Text('No possible explanations were returned.')]
                : report.analysis.possibleExplanations
                      .map(
                        (item) => _listItem(
                          '${item.name} - ${item.tag}',
                          item.description,
                          ink,
                          muted,
                        ),
                      )
                      .toList(),
          ),
          _sectionTitle('CYCLE CONTEXT AT CHECK-UP', rose),
          _card(divider, [
            _labelValue(
              'Cycle day',
              report.cycleContext.cycleDay == 0
                  ? 'Unknown'
                  : '${report.cycleContext.cycleDay}',
              ink,
              muted,
            ),
            _labelValue('Phase', report.cycleContext.phase, ink, muted),
            _labelValue(
              'Average cycle',
              '${report.cycleContext.averageCycleLength} days',
              ink,
              muted,
            ),
            _labelValue(
              'Last period',
              report.cycleContext.lastPeriod == null
                  ? 'Not recorded'
                  : _formatDate(report.cycleContext.lastPeriod!),
              ink,
              muted,
            ),
            _labelValue(
              'Regularity',
              report.cycleContext.regularity,
              ink,
              muted,
            ),
          ]),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: divider),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'HerAlth does not diagnose. This report is informational and should be reviewed with a qualified healthcare professional.',
              style: pw.TextStyle(color: muted, fontSize: 9, lineSpacing: 2),
            ),
          ),
        ],
      ),
    );
    return document.save();
  }

  pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 22, bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  pw.Widget _card(PdfColor border, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: border),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  pw.Widget _labelValue(
    String label,
    String value,
    PdfColor ink,
    PdfColor muted,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 105,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: muted, fontSize: 9),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(color: ink, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _listItem(
    String title,
    String detail,
    PdfColor ink,
    PdfColor muted,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: ink,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            detail,
            style: pw.TextStyle(color: muted, fontSize: 9, lineSpacing: 2),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
