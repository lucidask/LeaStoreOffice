import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/depot.dart';

class PDFDepotDetail {
  static Future<void> generateDepotPdf(Depot d, String clientNom) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/logo.jpg');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Détail du Dépôt d\'avance', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 20),
                  pw.Image(logo, width: 100),
                ],
              ),
               pw.SizedBox(height: 10),
              pw.Text('Client : $clientNom'),
              pw.Text('Montant : ${d.montant.toStringAsFixed(2)} HTG'),
              pw.Text('Date : ${d.date}'),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
