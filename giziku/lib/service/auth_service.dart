import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi registrasi yang sudah diperbaiki
  Future<User?> registerUser({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> extraData,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Menyimpan data pengguna ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': role, // Menyimpan peran yang dipilih
          'createdAt': FieldValue.serverTimestamp(),
          ...extraData,
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Fungsi login yang sudah diperbaiki
  // Sekarang mengembalikan UserCredential untuk mendapatkan UID
  Future<UserCredential> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
