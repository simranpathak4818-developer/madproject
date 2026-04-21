import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, String>?> uploadMaterial(String userId) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String fileExtension = fileName.split('.').last;
        String uniqueFileName =
            '${const Uuid().v4()}.$fileExtension';

        String filePath = 'materials/$userId/$uniqueFileName';

        TaskSnapshot uploadTask =
            await _storage.ref(filePath).putFile(file);
        String downloadUrl = await uploadTask.ref.getDownloadURL();

        return {
          'url': downloadUrl,
          'fileName': fileName,
          'filePath': filePath,
        };
      }
    } catch (e) {
      print('Upload Error: $e');
    }
    return null;
  }

  Future<bool> deleteFile(String filePath) async {
    try {
      await _storage.ref(filePath).delete();
      return true;
    } catch (e) {
      print('Delete Error: $e');
      return false;
    }
  }

  Future<int?> getFileSize(String fileUrl) async {
    try {
      final metadata = await _storage.refFromURL(fileUrl).getMetadata();
      return metadata.size;
    } catch (e) {
      print('Get File Size Error: $e');
      return null;
    }
  }
}