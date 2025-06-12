import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<User?> registerUser(
    String email,
    String password,
    String role,
    Map<String, dynamic> extraData,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          ...extraData, // tambahkan data tambahan seperti nama, vendor, sekolah
        });
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Login dan ambil role
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        DocumentSnapshot snapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          return snapshot['role'] as String;
        } else {
          throw Exception("User data not found");
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
