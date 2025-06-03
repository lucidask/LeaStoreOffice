import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/produit.dart';
import '../providers/achat_provider.dart';

class PDFInventaire {
  static Future<void> generatePdf({
    required List<Produit> produits,
    required AchatProvider achatProvider,
  }) async {
    final pdf = pw.Document();
    final formatCurrency = NumberFormat.currency(locale: 'fr_FR', symbol: 'HTG ');

    double totalAchat = 0.0;
    double totalVente = 0.0;

    final headers = [
      'Image',
      'Code',
      'Catégorie',
      'Prix Achat',
      'Prix Vente',
      'Quantité',
      'Valeur Achat',
      'Valeur Vente',
      'Marge',
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {
          return [
            pw.Text('Inventaire et Évaluation de Stock',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(width: 0.5),
              headerAlignment: pw.Alignment.center,
              cellAlignment: pw.Alignment.center,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: pw.TextStyle(fontSize: 9),
              headers: headers,
              columnWidths: {
                0: const pw.FixedColumnWidth(50),
                1: const pw.FixedColumnWidth(70),
                2: const pw.FixedColumnWidth(70),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(60),
                5: const pw.FixedColumnWidth(50),
                6: const pw.FixedColumnWidth(70),
                7: const pw.FixedColumnWidth(70),
                8: const pw.FixedColumnWidth(60),
              },
              data: produits.map((p) {
                final dernierAchat = achatProvider.dernierAchatPourProduit(p.id);
                final dernierPrixAchat = dernierAchat?.prixAchat ?? 0.0;
                final valeurAchat = p.stock * dernierPrixAchat;
                final valeurVente = p.stock * p.prixUnitaire;
                final marge = (p.prixUnitaire - dernierPrixAchat) * p.stock;

                totalAchat += valeurAchat;
                totalVente += valeurVente;

                return [
                  p.imagePath != null
                      ? pw.Image(pw.MemoryImage(File(p.imagePath!).readAsBytesSync()), width: 30, height: 30)
                      : 'N/A',
                  p.codeProduit,
                  p.categorie,
                  formatCurrency.format(dernierPrixAchat),
                  formatCurrency.format(p.prixUnitaire),
                  '${p.stock}',
                  formatCurrency.format(valeurAchat),
                  formatCurrency.format(valeurVente),
                  formatCurrency.format(marge),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Grand Total Achat : ${formatCurrency.format(totalAchat)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('Grand Total Vente : ${formatCurrency.format(totalVente)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ],
            ),
          ];
        },
      ),
    );

    // 📄 Affiche la boîte de dialogue d'impression PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
