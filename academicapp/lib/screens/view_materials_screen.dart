import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../models/material_model.dart';
import '../services/firestore_service.dart';
import 'pdf_viewer_screen.dart';

class ViewMaterialsScreen extends StatelessWidget {
  final UserModel user;
  final FirestoreService _firestoreService = FirestoreService();

  ViewMaterialsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Materials')),
      body: StreamBuilder<List<MaterialModel>>(
        stream: _firestoreService.getMaterials(user.branch, user.semester, user.section),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No materials available'),
                ],
              ),
            );
          }

          List<MaterialModel> materials = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              MaterialModel material = materials[index];
              return _buildMaterialCard(context, material);
            },
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, MaterialModel material) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFileIcon(material.fileName),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By: ${material.uploaderName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              material.description,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${material.uploadedAt.day}/${material.uploadedAt.month}/${material.uploadedAt.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.download, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${material.downloadCount} downloads',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewMaterial(context, material),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadMaterial(material),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewMaterial(BuildContext context, MaterialModel material) {
    if (material.fileName.toLowerCase().endsWith('.pdf')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PDFViewerScreen(material: material),
        ),
      );
    } else {
      _downloadMaterial(material);
    }
  }

  void _downloadMaterial(MaterialModel material) async {
    _firestoreService.incrementDownloadCount(material.id);
    
    if (await canLaunchUrl(Uri.parse(material.fileUrl))) {
      await launchUrl(
        Uri.parse(material.fileUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.ppt') ||
        fileName.toLowerCase().endsWith('.pptx')) {
      return Icons.slideshow;
    } else {
      return Icons.description;
    }
  }
}