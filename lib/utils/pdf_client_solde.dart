import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/client.dart';

class PDFClientSolde {
  static Future<void> generateSoldePdf(Client client) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Fiche Client', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Nom : ${client.nom}'),
              pw.Text('Téléphone : ${client.telephone ?? 'N/A'}'),
              pw.Text('Solde : ${client.solde.toStringAsFixed(2)} HTG'),
              pw.SizedBox(height: 20),
              pw.Text('Merci d’avoir choisi notre service.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
