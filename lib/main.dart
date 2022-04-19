import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_creater/product.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'generateInvoice.dart';

void main() {
  runApp(CreatePdfWidget());
}

class CreatePdfWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PdfWidget(),
    );
  }
}

class PdfWidget extends StatefulWidget {
  const PdfWidget({Key? key}) : super(key: key);

  @override
  State<PdfWidget> createState() => _PdfWidgetState();
}

class _PdfWidgetState extends State<PdfWidget> {
  final pdf = pw.Document();
  List<Product>? products = [];

  @override
  Widget build(BuildContext context) {
    products!.add(Product(name: "Turf / mtr", Price: 350, ProductPrice: 3.50, Qty: 100));
    products!.add(Product(name: "Soil", Price: 175, ProductPrice: 35, Qty: 5));
    // products!.add(Product(name: "Turf / mtr", Price: 350, ProductPrice: 3.50, Qty: 100));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter PDF Demo'),
        actions: [
          GestureDetector(
            onTap: () {
              saveAndLaunchFile("Invoice.pdf");
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Icon(Icons.save_alt),
            ),
          )
        ],
      ),
      body: Visibility(
        child: PdfPreview(
          canChangeOrientation: false,
          canChangePageFormat: false,
          allowPrinting: false,
          allowSharing: false,
          maxPageWidth: double.infinity,
          build: (format) => generateInvoice(format, pdf, products!),
        ),
        visible: true,
      ),
    );
  }

  Future<void> saveAndLaunchFile(String fileName) async {
    String? path;
    if (Platform.isAndroid) {
      final Directory directory = await getApplicationSupportDirectory();
      path = directory.path;
    } else {
      path = await PathProviderPlatform.instance.getApplicationSupportPath();
    }
    final File file = File(Platform.isWindows ? '$path\\$fileName' : '$path/$fileName');
    file.writeAsBytesSync(await pdf.save());
    if (Platform.isAndroid || Platform.isIOS) {
      await OpenFile.open('$path/$fileName');
    } else if (Platform.isWindows) {
      await Process.run('start', <String>['$path\\$fileName'], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.run('open', <String>['$path/$fileName'], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', <String>['$path/$fileName'], runInShell: true);
    }
  }
}
