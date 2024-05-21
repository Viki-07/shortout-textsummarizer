import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:groq/groq.dart';
import 'package:textsummarizer/screens/summarizedText.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final groq = Groq(
  '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',
  model: GroqModel.llama370b8192,
);

Future<String?> getSummaryfromGroq(String command) async {
  groq.startChat();

  try {
    GroqResponse response = await groq.sendMessage(command);
    return response.choices.first.message.content;
  } on GroqException {}
  return null;
}

Future<String?> getSummary(String text, int length, int style) {
  return getSummaryfromGroq(
      "Write summary for the following text $text in ${lengthOptions[length]} length and in ${styleOptions[style]} style");
}

final textController = TextEditingController();
ScrollController _scrollController = ScrollController();
int tagLength = 1;
List<String> lengthOptions = [
  'Very Short',
  'Short',
  'Medium',
  'Long',
];
int styleLength = 1;
List<String> styleOptions = [
  'Persuasive',
  'Neutral',
  'Informative',
];
Future<String?> _getClipboardText() async {
  final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  String? clipboardText = clipboardData?.text;
  return clipboardText;
}

Future<List<int>> _readDocumentData(String name) async {
  final ByteData data = ByteData.view(File(name).readAsBytesSync().buffer);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<String> extractText(String path) async {
  //Load an existing PDF document.
  PdfDocument document = PdfDocument(inputBytes: await _readDocumentData(path));

//Create a new instance of the PdfTextExtractor.
  PdfTextExtractor extractor = PdfTextExtractor(document);

//Extract all the text from the document.
  String text = extractor.extractText();
  return text;
}

Future<String> extractTextFromPdf() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    String text = await extractText(file.path!);
    return (text);
  } else {
    return "Unable to Read PDF";
  }
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Short-Out"),
      ),
      body: LoadingOverlay(
        progressIndicator: LoadingAnimationWidget.flickr(
            leftDotColor: Colors.amber,
            rightDotColor: Colors.blueAccent,
            size: 100),
        isLoading: _isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
                child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white10,
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(20)),
                    width: 355,
                    height: 320,
                    child: Column(
                      children: [
                        Scrollbar(
                          controller: _scrollController,
                          radius: const Radius.circular(20),
                          child: TextField(
                            controller: textController,
                            decoration: const InputDecoration.collapsed(
                                hintText: "Enter or Paste your text here..."),
                            maxLines: 10,
                            minLines: 10,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.file_upload_outlined),
                                onPressed: () async {
                                  String res = await extractTextFromPdf();
                                  setState(() {
                                    textController.text = res;
                                  });
                                },
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.paste_outlined),
                                onPressed: () async {
                                  String? copiedText =
                                      await _getClipboardText();
                                  setState(() {
                                    textController.text = copiedText!;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ))),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 15, 8, 8),
              child: Text(
                "Length",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 8, 0),
              child: SizedBox(
                width: 350,
                child: ChipsChoice<int>.single(
                  choiceStyle: const C2ChipStyle(
                    checkmarkColor: Colors.amber,
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.white,
                    borderStyle: BorderStyle.solid,
                  ),
                  wrapped: true,
                  choiceCheckmark: true,
                  value: tagLength,
                  choiceLabelBuilder: (item, i) {
                    return Text(
                      lengthOptions[i].toString(),
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    );
                  },
                  onChanged: (val) => setState(() => tagLength = val),
                  choiceItems: C2Choice.listFrom<int, String>(
                    source: lengthOptions,
                    value: (i, v) => i,
                    label: (i, v) => v,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 15, 8, 8),
              child: Text(
                "Style",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 8, 0),
              child: SizedBox(
                width: 400,
                child: ChipsChoice<int>.single(
                  choiceStyle: const C2ChipStyle(
                    checkmarkColor: Colors.amber,
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.white,
                    borderStyle: BorderStyle.solid,
                  ),
                  choiceCheckmark: true,
                  wrapped: true,
                  value: styleLength,
                  choiceLabelBuilder: (item, i) {
                    return Text(
                      styleOptions[i].toString(),
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    );
                  },
                  onChanged: (val) => setState(() => styleLength = val),
                  choiceItems: C2Choice.listFrom<int, String>(
                    source: styleOptions,
                    value: (i, v) => i,
                    label: (i, v) => v,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.blueAccent),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Summarize",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                  onPressed: () async {
                    if (textController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Enter text to summarize !")));
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    String? summText = await getSummary(
                        textController.text, tagLength, styleLength);

                    setState(() {
                      _isLoading = false;
                    });

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return SummarizedText(
                          summtext: summText ?? 'Failed to get summary',
                        );
                      },
                    ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
