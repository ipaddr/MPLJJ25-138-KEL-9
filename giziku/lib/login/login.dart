import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';
import '../service/auth_service.dart';
import '../user/dashboard.dart';
import '../vendor/dashboard_vendor.dart';
import '../admin/dashboard_admin.dart';

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
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua field.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Lakukan login
      final userCredential = await _authService.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Jika login berhasil, ambil data peran dari Firestore
      if (userCredential.user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (userDoc.exists) {
          final storedRole = userDoc.data()?['role'];

          // 3. Validasi peran
          if (storedRole == _selectedRole) {
            // Jika peran cocok, navigasi ke dashboard yang sesuai
            Widget destination;
            switch (storedRole) {
              case 'Admin Sekolah':
                destination = const DashboardAdmin();
                break;
              case 'Vendor Makanan':
                destination = const DashboardScreen();
                break;
              case 'User Biasa':
                destination = const HomeScreen();
                break;
              default:
                destination = const LoginScreen();
            }
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => destination),
              );
            }
          } else {
            // Jika peran tidak cocok, tampilkan error dan logout
            throw Exception(
              "Peran yang dipilih tidak sesuai dengan akun Anda.",
            );
          }
        } else {
          // Jika data user tidak ditemukan di Firestore
          throw Exception("Data pengguna tidak ditemukan di database.");
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan.";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = "Email atau password yang Anda masukkan salah.";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Menangkap error dari validasi peran atau error lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal login: ${e.toString().replaceAll("Exception: ", "")}",
          ),
        ),
      );
      await FirebaseAuth.instance
          .signOut(); // Logout paksa jika terjadi error setelah login
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan UI tidak diubah
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                                roles
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) =>
                                    setState(() => _selectedRole = value),
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
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Belum punya akun?? "),
                              GestureDetector(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const RegisterScreen(),
                                      ),
                                    ),
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
