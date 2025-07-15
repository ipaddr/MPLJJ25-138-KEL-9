import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController(); // Untuk Admin & Vendor

  String? _selectedRole;
  final List<String> _roles = ['User Biasa', 'Admin Sekolah', 'Vendor Makanan'];
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak cocok.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> extraData = {'username': _nameController.text};

      if (_selectedRole == 'Admin Sekolah') {
        extraData['sekolah'] = _schoolController.text;
      } else if (_selectedRole == 'Vendor Makanan') {
        extraData['vendorName'] = _schoolController.text;
      }

      await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole!,
        extraData: extraData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
        );
        Navigator.pop(context); // Kembali ke halaman login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendaftar: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat Akun Anda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap/Username',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => v!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        v != _passwordController.text
                            ? 'Password tidak cocok'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text('Pilih Peran Anda'),
                items:
                    _roles
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (v) => v == null ? 'Silakan pilih peran' : null,
              ),
              if (_selectedRole == 'Admin Sekolah' ||
                  _selectedRole == 'Vendor Makanan')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _schoolController,
                    decoration: InputDecoration(
                      labelText:
                          _selectedRole == 'Admin Sekolah'
                              ? 'Nama Sekolah'
                              : 'Nama Vendor',
                      border: const OutlineInputBorder(),
                    ),
                    validator:
                        (v) =>
                            v!.isEmpty ? 'Field ini tidak boleh kosong' : null,
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
