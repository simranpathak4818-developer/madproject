import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _isLoading = true;
    notifyListeners();

    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _fetchUserData(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Fetch User Error: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String branch,
    required String semester,
    required String section,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = UserModel(
        uid: userCred.user!.uid,
        email: email,
        name: name,
        role: role,
        branch: branch,
        semester: semester,
        section: section,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .set(_currentUser!.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign Up Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fetchUserData(userCred.user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign In Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get User Error: $e');
    }
    return null;
  }
}