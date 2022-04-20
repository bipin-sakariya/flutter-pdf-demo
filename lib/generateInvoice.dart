import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_pdf_creater/product.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateInvoice(PdfPageFormat pageFormat, Document pdf, List<Product> product) async {
  final invoice = Invoice(doc: pdf, products: product);
  return await invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({required this.doc, required this.products});

  final pw.Document doc;
  var assetImage;
  final List<Product> products;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    assetImage = pw.MemoryImage((await rootBundle.load("assets/logo.png")).buffer.asUint8List());

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
        ),
        build: (context) => [
          _contentInvoicejoyn(context),
          pw.Container(
            margin: pw.EdgeInsets.only(top: 30),
            alignment: Alignment.topRight,
            child: pw.Text("S Archibald",
                style: pw.TextStyle(fontSize: 15, color: PdfColors.black, fontWeight: pw.FontWeight.normal, fontBold: pw.Font.helvetica())),
          ),
          _contentInvoicedetails(context),
          pw.SizedBox(height: 20),
          _contentTabledetails(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 14),
          _contentFooterPayment(context)
        ],
      ),
    );
    return doc.save();
  }

  pw.PageTheme _buildTheme(PdfPageFormat pageFormat) {
    return pw.PageTheme(
      pageFormat: pageFormat,
    );
  }

  _contentInvoicejoyn(pw.Context context) {
    return pw.Container(
        width: double.infinity,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(height: 90, width: 90, child: pw.Image(assetImage)),
            pw.SizedBox(width: 30),
            pw.Container(
                margin: const pw.EdgeInsets.only(top: 0),
                child: pw.Text("Landscaping Brisbane",
                    style: pw.TextStyle(
                        fontSize: 26, fontWeight: pw.FontWeight.bold, fontBold: pw.Font.helveticaBold(), color: PdfColor.fromHex("#2660a6")))),
            pw.Container(
                margin: const pw.EdgeInsets.only(top: 80),
                child: pw.Text("Tax Invoice",
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, fontBold: pw.Font.helveticaBold(), color: PdfColors.black))),
            pw.SizedBox(width: 20)
          ],
        ));
  }

  _contentInvoicedetails(pw.Context context) {
    return pw.Container(
        width: double.infinity,
        child: pw.Column(children: [
          pw.Row(children: [
            pw.Text("ABN: 897 456 7896",
                style: pw.TextStyle(
                    fontSize: 15, color: PdfColors.black, fontWeight: pw.FontWeight.normal, fontBold: pw.Font.helvetica(), lineSpacing: 1.5)),
          ]),
          pw.SizedBox(height: 20),
          pw.Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
            pw.Align(
              alignment: Alignment.centerLeft,
              child: pw.Text("40 Craigmont Street\n\nWest Albany, Hn4568",
                  style: pw.TextStyle(
                      fontSize: 15, color: PdfColors.black, fontWeight: pw.FontWeight.normal, fontBold: pw.Font.helvetica(), lineSpacing: 1.5)),
            ),
            pw.Text('Inv'),
            pw.Text('1000'),
          ]),
          //pw.SizedBox(height: 10),
          pw.Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [pw.SizedBox(width: 180), pw.Text("Issued"), pw.Text("1/05/2022")]),
          pw.SizedBox(height: 10),
          pw.Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
            pw.SizedBox(
                width: 175,
                child: pw.FittedBox(
                  child: pw.Text("greg@landscapingbrisbane.com.au",
                      style: pw.TextStyle(
                          fontSize: 15, color: PdfColors.black, fontWeight: pw.FontWeight.normal, fontBold: pw.Font.helvetica(), lineSpacing: 1.5)),
                )),
            pw.Text("Due"),
            pw.Text("15/05/2022")
          ]),
        ]));
  }

  pw.Widget _contentTabledetails(pw.Context context) {
    var tableHeaders = ["No", "DESCRIPTION", "QTY(hrs)", "RATE", "TOTAL"];
    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 1))),
      headerHeight: 20,
      cellHeight: 25,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        color: PdfColors.black,
        fontSize: 12,
        fontBold: pw.Font.helvetica(),
        fontWeight: pw.FontWeight.normal,
      ),
      cellStyle: pw.TextStyle(
        color: PdfColors.black,
        fontSize: 12,
        fontBold: pw.Font.helvetica(),
        fontWeight: pw.FontWeight.normal,
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey,
            width: 1,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        products.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => products[row].getIndex(col, row),
        ),
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 2, child: pw.Container()),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Subtotal",
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.black,
                        fontBold: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    pw.Text("\$525.00",
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                          fontBold: pw.Font.helvetica(),
                          fontWeight: pw.FontWeight.normal,
                        )),
                  ],
                ),
                pw.Divider(color: PdfColors.grey),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Discount",
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.black,
                        fontBold: pw.Font.helvetica(),
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    pw.Text("0%",
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                          fontBold: pw.Font.helvetica(),
                          fontWeight: pw.FontWeight.normal,
                        )),
                  ],
                ),
                pw.Divider(color: PdfColors.grey),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("GST",
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                          fontBold: pw.Font.helvetica(),
                          fontWeight: pw.FontWeight.normal,
                        )),
                    pw.Text("\$52.50",
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.black,
                          fontBold: pw.Font.helvetica(),
                          fontWeight: pw.FontWeight.normal,
                        )),
                  ],
                ),
                pw.Divider(color: PdfColors.grey),
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Total",
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.black,
                            fontBold: pw.Font.helveticaBold(),
                            fontWeight: pw.FontWeight.bold,
                          )),
                      pw.Text("\$577.50",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontBold: pw.Font.helveticaBold(),
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooterPayment(pw.Context context) {
    return pw.Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pw.Text("PAYMENT DETAILS"),
      pw.Divider(color: PdfColors.grey),
      pw.Text("Pay via direct deposit to:"),
      pw.SizedBox(height: 4),
      pw.Text("Account Name"),
      pw.SizedBox(height: 4),
      pw.Text("BSB: 015-600"),
      pw.SizedBox(height: 4),
      pw.Text("Account: 8974561"),
      pw.SizedBox(height: 10),
      pw.Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [pw.Text("Pay via PayPal to:\nEmail Address Here"), pw.Text("Thank you!\nIt's been a pleasure working with you this month.")])
    ]);
  }
}
