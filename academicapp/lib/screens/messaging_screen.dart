import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingScreen extends StatefulWidget {
  final UserModel user;

  const MessagingScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsList(),
          _buildUsersList(),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getChatList(widget.user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No chats yet'),
              ],
            ),
          );
        }

        List<Map<String, dynamic>> chats = snapshot.data!;
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chat = chats[index];
            String otherUserId = (chat['participants'] as List)
                .firstWhere((id) => id != widget.user.uid);

            return FutureBuilder<UserModel?>(
              future: _getUser(otherUserId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                UserModel otherUser = userSnapshot.data!;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(otherUser.name[0].toUpperCase()),
                  ),
                  title: Text(otherUser.name),
                  subtitle: Text(
                    chat['lastMessage'] ?? 'No messages',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        currentUser: widget.user,
                        otherUser: otherUser,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: widget.user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<UserModel> users = snapshot.data!.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            UserModel otherUser = users[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(otherUser.name[0].toUpperCase()),
              ),
              title: Text(otherUser.name),
              subtitle: Text('${otherUser.role} | ${otherUser.email}'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                    currentUser: widget.user,
                    otherUser: otherUser,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<UserModel?> _getUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}

class ChatDetailScreen extends StatefulWidget {
  final UserModel currentUser;
  final UserModel otherUser;

  const ChatDetailScreen({
    Key? key,
    required this.currentUser,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _firestoreService.getMessages(
                widget.currentUser.uid,
                widget.otherUser.uid,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<MessageModel> messages = snapshot.data!;
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
                    MessageModel message = messages[index];
                    bool isMe = message.senderId == widget.currentUser.uid;

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
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(message.timestamp),
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

    bool success = await _firestoreService.sendMessage(
      senderId: widget.currentUser.uid,
      senderName: widget.currentUser.name,
      receiverId: widget.otherUser.uid,
      message: _messageController.text,
    );

    if (success) {
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}