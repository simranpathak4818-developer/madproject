import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/material_model.dart';
import '../models/message_model.dart';
import '../models/group_chat_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===================== MATERIALS =====================

  Future<bool> uploadMaterial({
    required String userId,
    required String title,
    required String description,
    required String branch,
    required String semester,
    required String section,
    required String fileUrl,
    required String fileName,
    required String uploaderName,
  }) async {
    try {
      String materialId = const Uuid().v4();
      await _firestore.collection('materials').doc(materialId).set({
        'id': materialId,
        'title': title,
        'description': description,
        'branch': branch,
        'semester': semester,
        'section': section,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'uploadedBy': userId,
        'uploaderName': uploaderName,
        'uploadedAt': DateTime.now().toIso8601String(),
        'downloadCount': 0,
      });
      return true;
    } catch (e) {
      print('Upload Material Error: $e');
      return false;
    }
  }

  Stream<List<MaterialModel>> getMaterials(
    String branch,
    String semester,
    String section,
  ) {
    return _firestore
        .collection('materials')
        .where('branch', isEqualTo: branch)
        .where('semester', isEqualTo: semester)
        .where('section', isEqualTo: section)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MaterialModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<MaterialModel>> getAllMaterials(String userId) {
    return _firestore
        .collection('materials')
        .where('uploadedBy', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MaterialModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<bool> deleteMaterial(String materialId) async {
    try {
      await _firestore.collection('materials').doc(materialId).delete();
      return true;
    } catch (e) {
      print('Delete Material Error: $e');
      return false;
    }
  }

  Future<void> incrementDownloadCount(String materialId) async {
    try {
      await _firestore.collection('materials').doc(materialId).update({
        'downloadCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Increment Download Error: $e');
    }
  }

  // ===================== 1-1 MESSAGING =====================

  Future<bool> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String message,
  }) async {
    try {
      String chatId = _getChatId(senderId, receiverId);
      String messageId = const Uuid().v4();

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      await _firestore.collection('chats').doc(chatId).set({
        'participants': [senderId, receiverId],
        'lastMessage': message,
        'lastMessageTime': DateTime.now().toIso8601String(),
        'lastMessageSenderId': senderId,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Send Message Error: $e');
      return false;
    }
  }

  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    String chatId = _getChatId(senderId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getChatList(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // ===================== GROUP CHAT =====================

  Future<String?> createGroupChat({
    required String groupName,
    required List<String> memberIds,
    required List<String> memberNames,
    required String createdBy,
    String? description,
  }) async {
    try {
      String groupId = const Uuid().v4();
      await _firestore.collection('groupChats').doc(groupId).set({
        'id': groupId,
        'name': groupName,
        'memberIds': memberIds,
        'memberNames': memberNames,
        'createdBy': createdBy,
        'createdAt': DateTime.now().toIso8601String(),
        'description': description,
      });
      return groupId;
    } catch (e) {
      print('Create Group Chat Error: $e');
      return null;
    }
  }

  Stream<List<GroupChatModel>> getUserGroupChats(String userId) {
    return _firestore
        .collection('groupChats')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupChatModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<bool> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    try {
      String messageId = const Uuid().v4();
      await _firestore
          .collection('groupChats')
          .doc(groupId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _firestore.collection('groupChats').doc(groupId).update({
        'lastMessage': message,
        'lastMessageTime': DateTime.now().toIso8601String(),
        'lastMessageSenderId': senderId,
      });

      return true;
    } catch (e) {
      print('Send Group Message Error: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groupChats')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  String _getChatId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }
}