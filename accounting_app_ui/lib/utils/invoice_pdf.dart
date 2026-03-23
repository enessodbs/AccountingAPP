import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';

/// Fatura detayından PDF belgesi oluşturur ve yazdırma/indirme dialogunu açar
Future<void> generateAndPrintInvoicePdf(InvoiceDetail detail) async {
  // Load a font that supports Turkish characters
  final font = await PdfGoogleFonts.notoSansRegular();
  final fontBold = await PdfGoogleFonts.notoSansBold();

  final baseStyle = pw.TextStyle(font: font, fontSize: 10);
  final boldStyle = pw.TextStyle(font: fontBold, fontSize: 10);
  final headerStyle = pw.TextStyle(font: fontBold, fontSize: 28, color: PdfColor.fromHex('#1E3A8A'));
  final smallStyle = pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700);
  final smallBold = pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromHex('#1E3A8A'));

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('FATURA', style: headerStyle),
                    pw.SizedBox(height: 4),
                    pw.Text(detail.invoiceNumber, style: smallStyle),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      detail.type == 1 ? 'Giden Fatura (Satış)' : 'Gelen Fatura (Alım)',
                      style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Düzenleme: ${_formatDate(detail.issueDate)}', style: baseStyle),
                    pw.Text('Vade: ${_formatDate(detail.dueDate)}', style: baseStyle),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColor.fromHex('#1E3A8A'), thickness: 2),
            pw.SizedBox(height: 16),

            // ─── İş Ortağı Bilgileri ───
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3F4F6'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('İş Ortağı Bilgileri', style: smallBold),
                  pw.SizedBox(height: 6),
                  pw.Text(detail.contactName, style: pw.TextStyle(font: fontBold, fontSize: 12)),
                  if (detail.contactTaxNumber != null && detail.contactTaxNumber!.isNotEmpty)
                    pw.Text('Vergi No: ${detail.contactTaxNumber}', style: baseStyle),
                  if (detail.contactTaxOffice != null && detail.contactTaxOffice!.isNotEmpty)
                    pw.Text('Vergi Dairesi: ${detail.contactTaxOffice}', style: baseStyle),
                  if (detail.contactAddress != null && detail.contactAddress!.isNotEmpty)
                    pw.Text('Adres: ${detail.contactAddress}', style: baseStyle),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // ─── Kalemler Tablosu ───
            pw.TableHelper.fromTextArray(
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
              cellStyle: baseStyle,
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E3A8A')),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              headerPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              headers: ['Ürün', 'Miktar', 'Birim Fiyat', 'KDV %', 'Toplam'],
              data: detail.lines.map((line) => [
                line.productName,
                line.quantity.toStringAsFixed(0),
                '${line.unitPrice.toStringAsFixed(2)} ${detail.currencyCode}',
                '%${line.taxRate.toStringAsFixed(0)}',
                '${line.lineTotal.toStringAsFixed(2)} ${detail.currencyCode}',
              ]).toList(),
            ),
            pw.SizedBox(height: 16),

            // ─── Toplamlar ───
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 220,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F3F4F6'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  children: [
                    _buildTotalRow('Ara Toplam', '${detail.subTotal.toStringAsFixed(2)} ${detail.currencyCode}', baseStyle),
                    pw.SizedBox(height: 4),
                    _buildTotalRow('KDV', '${detail.taxAmount.toStringAsFixed(2)} ${detail.currencyCode}', baseStyle),
                    pw.Divider(color: PdfColors.grey400),
                    _buildTotalRow('TOPLAM', '${detail.totalAmount.toStringAsFixed(2)} ${detail.currencyCode}',
                        pw.TextStyle(font: fontBold, fontSize: 14)),
                  ],
                ),
              ),
            ),
            pw.Spacer(),

            // ─── Footer ───
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text('Bu belge elektronik ortamda oluşturulmuştur.',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500)),
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: '${detail.invoiceNumber}.pdf',
  );
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

pw.Widget _buildTotalRow(String label, String value, pw.TextStyle style) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: style),
      pw.Text(value, style: style),
    ],
  );
}
