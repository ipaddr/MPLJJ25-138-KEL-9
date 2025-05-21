import 'package:flutter/material.dart';
import 'profil_admin.dart';

class EditProfileAdmin extends StatelessWidget {
  EditProfileAdmin({super.key});

  final TextEditingController _npsnController = TextEditingController();
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _studentsCountController =
      TextEditingController();

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileAdmin()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _npsnController,
                maxLines: 1,
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
                hint: 'Contoh: Admin Sekolah',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                maxLines: 3,
                controller: _addressController,
                label: 'Alamat',
                hint: 'Contoh: Jl. Anggrek No 12, Padang Barat',
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
                  onPressed: () {
                    // Simpan data
                  },
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
}
