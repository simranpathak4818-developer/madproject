import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/group_chat_model.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatScreen extends StatefulWidget {
  final UserModel user;

  const GroupChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Study'),
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(text: 'Groups'),
            Tab(text: 'Create'),
          ],
        ),
      ),
      body: _selectedTab == 0 ? _buildGroupsList() : _buildCreateGroup(),
    );
  }

  Widget _buildGroupsList() {
    return StreamBuilder<List<GroupChatModel>>(
      stream: _firestoreService.getUserGroupChats(widget.user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No group chats yet'),
              ],
            ),
          );
        }

        List<GroupChatModel> groups = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            GroupChatModel group = groups[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.group),
                  backgroundColor: Colors.blue[100],
                ),
                title: Text(group.name),
                subtitle: Text(
                  '${group.memberIds.length} members',
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatDetailScreen(
                      group: group,
                      currentUser: widget.user,
                    ),
                  ),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('View Members'),
                      onTap: () => _showMembers(context, group),
                    ),
                    PopupMenuItem(
                      child: const Text('Leave Group'),
                      onTap: () => _leaveGroup(context, group),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateGroup() {
    final _groupNameController = TextEditingController();
    final _descriptionController = TextEditingController();
    List<String> _selectedMembers = [];

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Members',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', isNotEqualTo: widget.user.uid)
                    .where('branch', isEqualTo: widget.user.branch)
                    .where('semester', isEqualTo: widget.user.semester)
                    .where('section', isEqualTo: widget.user.section)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  List<UserModel> users = snapshot.data!.docs
                      .map((doc) =>
                          UserModel.fromMap(doc.data() as Map<String, dynamic>))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      UserModel u = users[index];
                      bool isSelected = _selectedMembers.contains(u.uid);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedMembers.add(u.uid);
                            } else {
                              _selectedMembers.remove(u.uid);
                            }
                          });
                        },
                        title: Text(u.name),
                        subtitle: Text(u.email),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    _createGroup(
                      _groupNameController.text,
                      _descriptionController.text,
                      _selectedMembers,
                    );
                  },
                  child: const Text('Create Group'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createGroup(
    String groupName,
    String description,
    List<String> memberIds,
  ) async {
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter group name')),
      );
      return;
    }

    if (memberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    memberIds.add(widget.user.uid);
    List<String> memberNames = [widget.user.name];

    for (String memberId in memberIds) {
      if (memberId != widget.user.uid) {
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('users').doc(memberId).get();
        memberNames.add(doc['name']);
      }
    }

    String? groupId = await _firestoreService.createGroupChat(
      groupName: groupName,
      memberIds: memberIds,
      memberNames: memberNames,
      createdBy: widget.user.uid,
      description: description,
    );

    if (groupId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully')),
      );
      setState(() => _selectedTab = 0);
    }
  }

  void _showMembers(BuildContext context, GroupChatModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: group.memberIds.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(group.memberNames[index]),
                trailing: group.createdBy == group.memberIds[index]
                    ? const Chip(label: Text('Admin'))
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _leaveGroup(BuildContext context, GroupChatModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Left group')),
              );
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class GroupChatDetailScreen extends StatefulWidget {
  final GroupChatModel group;
  final UserModel currentUser;

  const GroupChatDetailScreen({
    Key? key,
    required this.group,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<GroupChatDetailScreen> createState() => _GroupChatDetailScreenState();
}

class _GroupChatDetailScreenState extends State<GroupChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getGroupMessages(widget.group.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == widget.currentUser.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                message['senderName'] ?? 'User',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              message['message'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(
                                DateTime.parse(message['timestamp']),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    await _firestoreService.sendGroupMessage(
      groupId: widget.group.id,
      senderId: widget.currentUser.uid,
      senderName: widget.currentUser.name,
      message: _messageController.text,
    );

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}