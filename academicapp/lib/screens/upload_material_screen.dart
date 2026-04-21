import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UploadMaterialScreen extends StatefulWidget {
  final String userId;

  const UploadMaterialScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedBranch, _selectedSemester, _selectedSection;
  Map<String, String>? _uploadedFile;
  bool _isUploading = false;

  final List<String> _branches = ['CS', 'IT', 'EC', 'ME'];
  final List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> _sections = ['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedBranch,
              items: _branches.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => _selectedBranch = value),
              decoration: InputDecoration(
                labelText: 'Branch',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSemester,
              items: _semesters
                  .map((e) => DropdownMenuItem(value: e, child: Text('Semester $e')))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSemester = value),
              decoration: InputDecoration(
                labelText: 'Semester',
                prefixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSection,
              items: _sections
                  .map((e) => DropdownMenuItem(value: e, child: Text('Section $e')))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSection = value),
              decoration: InputDecoration(
                labelText: 'Section',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _uploadedFile == null ? _pickAndUploadFile : null,
              icon: const Icon(Icons.cloud_upload),
              label: Text(_uploadedFile == null ? 'Select & Upload File' : 'File Selected'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            if (_uploadedFile != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File: ${_uploadedFile!['fileName']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitMaterial,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Material'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickAndUploadFile() async {
    if (_selectedBranch == null || _selectedSemester == null || _selectedSection == null) {
      _showSnackBar('Please select branch, semester, and section');
      return;
    }

    setState(() => _isUploading = true);
    Map<String, String>? result = await _storageService.uploadMaterial(widget.userId);
    setState(() => _isUploading = false);

    if (result != null) {
      setState(() => _uploadedFile = result);
      _showSnackBar('File uploaded successfully', isError: false);
    } else {
      _showSnackBar('Failed to upload file');
    }
  }

  void _submitMaterial() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter title');
      return;
    }
    if (_uploadedFile == null) {
      _showSnackBar('Please upload a file');
      return;
    }

    setState(() => _isUploading = true);

    final currentUser = context.read<AuthProvider>().currentUser;
    bool success = await _firestoreService.uploadMaterial(
      userId: widget.userId,
      title: _titleController.text,
      description: _descriptionController.text,
      branch: _selectedBranch!,
      semester: _selectedSemester!,
      section: _selectedSection!,
      fileUrl: _uploadedFile!['url']!,
      fileName: _uploadedFile!['fileName']!,
      uploaderName: currentUser?.name ?? 'Unknown',
    );

    setState(() => _isUploading = false);

    if (success) {
      _showSnackBar('Material uploaded successfully', isError: false);
      Navigator.pop(context);
    } else {
      _showSnackBar('Failed to upload material');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}