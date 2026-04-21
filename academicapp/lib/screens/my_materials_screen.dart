import 'package:flutter/material.dart';
import '../models/material_model.dart';
import '../services/firestore_service.dart';

class MyMaterialsScreen extends StatelessWidget {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  MyMaterialsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Uploaded Materials')),
      body: StreamBuilder<List<MaterialModel>>(
        stream: _firestoreService.getAllMaterials(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No materials uploaded yet'),
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  leading: Icon(
                    _getFileIcon(material.fileName),
                    color: Colors.blue,
                  ),
                  title: Text(material.title),
                  subtitle: Text(
                    '${material.branch} - Sem ${material.semester} - Sec ${material.section}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _editMaterial(context, material),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => _deleteMaterial(context, material),
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Downloads: ${material.downloadCount}',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editMaterial(BuildContext context, MaterialModel material) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _deleteMaterial(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _firestoreService.deleteMaterial(material.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Material deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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