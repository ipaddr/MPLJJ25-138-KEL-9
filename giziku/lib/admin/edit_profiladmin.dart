import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profil_admin.dart';

class EditProfileAdmin extends StatefulWidget {
  const EditProfileAdmin({super.key});

  @override
  State<EditProfileAdmin> createState() => _EditProfileAdminState();
}

class _EditProfileAdminState extends State<EditProfileAdmin> {
  final TextEditingController _npsnController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _studentsCountController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        _npsnController.text = data['npsn'] ?? '';
        _responsibleController.text = data['responsible'] ?? '';
        _positionController.text = data['position'] ?? '';
        _addressController.text = data['address'] ?? '';
        _studentsCountController.text = (data['students'] ?? '').toString();
      }
    }
  }

  Future<void> _saveData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'npsn': _npsnController.text.trim(),
        'responsible': _responsibleController.text.trim(),
        'position': _positionController.text.trim(),
        'address': _addressController.text.trim(),
        'students': int.tryParse(_studentsCountController.text.trim()) ?? 0,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileAdmin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF4E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTextField(
                controller: _npsnController,
                label: 'NPSN',
                hint: 'Contoh: 123456789',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _responsibleController,
                label: 'Penanggung Jawab',
                hint: 'Contoh: Ibu Putri',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _positionController,
                label: 'Jabatan',
                hint: 'Contoh: Kepala Sekolah',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Alamat',
                hint: 'Contoh: Jl. Anggrek No. 12, Padang Barat',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _studentsCountController,
                label: 'Jumlah Siswa',
                hint: 'Contoh: 320',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saveData,
                  child: const Text(
                    'Update Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFA726)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _npsnController.dispose();
    _responsibleController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _studentsCountController.dispose();
    super.dispose();
  }
}
