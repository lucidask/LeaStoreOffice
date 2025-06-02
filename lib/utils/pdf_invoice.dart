import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/transaction_item.dart';

class PDFInvoice {
  static Future<void> generateInvoice({
    required String factureId,
    required String clientNom,
    required String date,
    required String modePaiement,
    required List<TransactionItem> produits,
    required double versement,
    required double depotUtilise,
  }) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle('assets/logo.jpg');

    final total = produits.fold(0.0, (sum, item) => sum + item.quantite * item.prixUnitaire);
    final balance = (total - versement - depotUtilise).clamp(0.0, double.infinity);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Facture de Vente', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 20),
                    pw.Image(logo, width: 100),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text('Numéro de facture: $factureId'),
                pw.Text('Client: $clientNom'),
                pw.Text('Date: $date'),
                pw.Text('Mode de paiement: $modePaiement'),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Produit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qté', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Prix', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...produits.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.produitNom)),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.quantite.toString())),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${item.prixUnitaire.toStringAsFixed(2)} HTG')),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${(item.quantite * item.prixUnitaire).toStringAsFixed(2)} HTG')),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.Divider(),

                // ✅ Total, Versement et Balance bien alignés
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total : ${total.toStringAsFixed(2)} HTG', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Versement : ${versement.toStringAsFixed(2)} HTG', style: pw.TextStyle(fontSize: 14)),
                      if (depotUtilise > 0.01)
                        pw.Text('Dépôt utilisé : ${depotUtilise.toStringAsFixed(2)} HTG', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Balance : ${balance.toStringAsFixed(2)} HTG', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),
                pw.Text('Merci pour votre achat !', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}