import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../models/material_model.dart';
import '../services/firestore_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final MaterialModel material;

  const PDFViewerScreen({Key? key, required this.material}) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfControllerPinch _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initializePDF();
    _firestoreService.incrementDownloadCount(widget.material.id);
  }

  void _initializePDF() async {
    try {
      // Download PDF from URL
      final response = await http.get(Uri.parse(widget.material.fileUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${widget.material.id}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        // Open PDF from local file
        _pdfController = PdfControllerPinch(
          initialPage: 1,
          document: PdfDocument.openFile(file.path),
        );

        final document = await PdfDocument.openFile(file.path);
        setState(() {
          _totalPages = document.pagesCount;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      print('PDF Load Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.title),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                PdfViewPinch(
                  controller: _pdfController,
                  onDocumentLoaded: (document) {
                    setState(() => _totalPages = document.pagesCount);
                  },
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _currentPage > 1
                              ? () => _pdfController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  )
                              : null,
                        ),
                        Text(
                          'Page $_currentPage / $_totalPages',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                          onPressed: _currentPage < _totalPages
                              ? () => _pdfController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}