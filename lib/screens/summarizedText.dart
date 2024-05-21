import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter_share/flutter_share.dart';

class SummarizedText extends StatefulWidget {
  final summtext;
  const SummarizedText({this.summtext, super.key});

  @override
  State<SummarizedText> createState() => _SummarizedTextState();
}

ScrollController _scrollController = ScrollController();

Future<void> saveAsPDF(String summText) async {
  // Create a new PDF document.
  final PdfDocument document = PdfDocument();
// Add a PDF page and draw text.
  document.pages.add().graphics.drawString(
      summText, PdfStandardFont(PdfFontFamily.helvetica, 15),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      bounds: const Rect.fromLTWH(0, 0, 500, 8000));
  final List<int> bytes = await document.save();
  Uint8List textBytes1 = Uint8List.fromList(bytes);

// Save the document.
  // await FileSaveHelper.saveAndLaunchFile(bytes, 'Invoice.pdf');
  try {
    DocumentFileSavePlus().saveFile(textBytes1,
        "ShortOutSummary${Random().nextInt(1000)}.pdf", "appliation/pdf");
  } catch (e) {}

// Dispose the document.
  document.dispose();
}

class _SummarizedTextState extends State<SummarizedText> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summarized Text'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.outlined(
                onPressed: () {
                  FlutterShare.share(
                    title: 'Short-Out',
                    text: widget.summtext,
                  );
                },
                icon: const Icon(Icons.share)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: 370,
              height: 500,
              child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Scrollbar(
                      controller: _scrollController,
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Text(
                            widget.summtext,
                            style: const TextStyle(fontSize: 18),
                          )),
                    ),
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                  icon: const Icon(
                    Icons.file_download_outlined,
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    saveAsPDF(widget.summtext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Summary Saved as PDF, Check Files!")));
                  },
                  label: const Text("Save as PDF")),
              const SizedBox(
                width: 50,
              ),
              ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    await Clipboard.setData(
                            ClipboardData(text: widget.summtext))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Summary Copied to Clipboard!")));
                    });
                  },
                  label: const Text("Copy Text")),
            ],
          )
        ],
      ),
    );
  }
}
