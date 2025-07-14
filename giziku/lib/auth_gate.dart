import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giziku/admin/dashboard_admin.dart'; // Sesuaikan path
import 'package:giziku/login/login.dart'; // Sesuaikan path
import 'package:giziku/user/dashboard.dart'; // Sesuaikan path
import 'package:giziku/vendor/dashboard_vendor.dart'; // Sesuaikan path
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika pengguna belum login, tampilkan halaman login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Jika ada pengguna yang login, periksa perannya
        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (userSnapshot.hasError || !userSnapshot.data!.exists) {
              return const LoginScreen();
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'];

            // Arahkan berdasarkan peran (role)
            switch (role) {
              case 'Admin Sekolah':
                return const DashboardAdmin();
              case 'Vendor Makanan':
                return const DashboardScreen(); // Pastikan nama class ini benar
              case 'User Biasa':
                return const HomeScreen();
              default:
                return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
