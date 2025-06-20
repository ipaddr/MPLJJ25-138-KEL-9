import 'package:flutter/material.dart';
import 'register.dart';
import '../user/dashboard.dart';
import '../vendor/dashboard_vendor.dart';
import '../admin/dashboard_admin.dart';
import '../service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;

  final List<String> roles = ['User Biasa', 'Admin Sekolah', 'Vendor Makanan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header orange penuh
            Container(
              height: 50,
              decoration: const BoxDecoration(color: Colors.orange),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'GiziKu',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Konten
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 30),
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            ' Selamat Datang...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Login untuk melanjutkan',
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 50),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                              hintText: 'Masukkan email',
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              hintText: 'Masukkan password',
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items:
                                roles.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Pilih role',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_selectedRole == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Silakan pilih role terlebih dahulu.",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final user = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );

                                  final uid = user.user!.uid;
                                  final doc =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .get();

                                  if (!doc.exists) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Data pengguna tidak ditemukan di Firestore.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final storedRole = doc['role'];

                                  if (storedRole != _selectedRole) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Role tidak sesuai"),
                                      ),
                                    );
                                    await FirebaseAuth.instance
                                        .signOut(); // logout paksa
                                    return;
                                  }

                                  // Arahkan ke halaman dashboard sesuai role
                                  if (storedRole == 'User Biasa') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomeScreen(),
                                      ),
                                    );
                                  } else if (storedRole == 'Vendor Makanan') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DashboardScreen(),
                                      ),
                                    );
                                  } else if (storedRole == 'Admin Sekolah') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DashboardAdmin(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Login gagal! Kredensial tidak valid",
                                      ),
                                    ),
                                  );
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Belum punya akun?? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
