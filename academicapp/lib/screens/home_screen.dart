import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'upload_material_screen.dart';
import 'view_materials_screen.dart';
import 'messaging_screen.dart';
import 'group_chat_screen.dart';
import 'my_materials_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Resource Sharing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(widget.user.name[0].toUpperCase()),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.user.role.toUpperCase()} | ${widget.user.email}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.user.branch} - Sem ${widget.user.semester} - Sec ${widget.user.section}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.user.role == 'faculty')
                _buildMenuButton(
                  context,
                  'Upload Material',
                  Icons.upload_file,
                  Colors.blue,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UploadMaterialScreen(userId: widget.user.uid),
                    ),
                  ),
                ),
              if (widget.user.role == 'faculty')
                const SizedBox(height: 12),
              if (widget.user.role == 'faculty')
                _buildMenuButton(
                  context,
                  'My Materials',
                  Icons.my_library_books,
                  Colors.purple,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MyMaterialsScreen(userId: widget.user.uid),
                    ),
                  ),
                ),
              if (widget.user.role == 'faculty')
                const SizedBox(height: 12),
              _buildMenuButton(
                context,
                'View Materials',
                Icons.description,
                Colors.green,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ViewMaterialsScreen(user: widget.user),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                'Messages',
                Icons.chat,
                Colors.orange,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MessagingScreen(user: widget.user),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                'Group Study',
                Icons.groups,
                Colors.red,
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupChatScreen(user: widget.user),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onPressed,
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}