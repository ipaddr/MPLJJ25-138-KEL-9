// lib/recipient.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipientDataScreen extends StatefulWidget {
  const RecipientDataScreen({super.key});

  @override
  State<RecipientDataScreen> createState() => _RecipientDataScreenState();
}

class _RecipientDataScreenState extends State<RecipientDataScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  // Controller baru untuk Nomor Induk Siswa
  final TextEditingController _studentIdController = TextEditingController();

  String? _selectedGender;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _gradeController.dispose();
    _classController.dispose();
    _studentIdController.dispose(); // Jangan lupa di-dispose
    super.dispose();
  }

  Future<void> _saveRecipientData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anda harus login untuk menyimpan data.")),
      );
      return;
    }

    // Validasi semua field, termasuk Nomor Induk Siswa
    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _selectedGender == null ||
        _gradeController.text.isEmpty ||
        _classController.text.isEmpty ||
        _studentIdController.text.isEmpty) {
      // Tambahkan validasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
      return;
    }

    try {
      // Menyimpan data ke koleksi 'recipients'
      await FirebaseFirestore.instance.collection('recipients').add({
        'userId': user.uid,
        'nama': _nameController.text,
        'tanggalLahir': _dobController.text,
        'jenisKelamin': _selectedGender,
        'grade': _gradeController.text,
        'kelas': _classController.text,
        'studentId': _studentIdController.text, // Tambahkan field baru
        'timestamp': FieldValue.serverTimestamp(),
        'statusDistribusi': 'belum_terdistribusi',
        'tanggalDistribusi': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data penerima berhasil disimpan")),
      );

      // Membersihkan semua controller
      _nameController.clear();
      _dobController.clear();
      _gradeController.clear();
      _classController.clear();
      _studentIdController.clear();
      setState(() => _selectedGender = null);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7EF),
      appBar: AppBar(
        backgroundColor: orangeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Tambah Data Penerima',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            buildLabel("Nama"),
            buildTextField(
              controller: _nameController,
              hintText: "Nama Lengkap",
            ),
            buildLabel("Nomor Induk Siswa"), // Label baru
            buildTextField(
              controller: _studentIdController,
              hintText: "Contoh: 12345678",
              keyboardType: TextInputType.number, // Keyboard numerik
            ),
            buildLabel("Tanggal Lahir"),
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "dd/mm/yyyy",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2015),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dobController.text =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            buildLabel("Jenis Kelamin"),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: const Text("Pilih Jenis Kelamin"),
              items:
                  genderOptions
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            buildLabel("Tingkat"),
            buildTextField(controller: _gradeController, hintText: "Ex: 5"),
            buildLabel("Kelas"),
            buildTextField(controller: _classController, hintText: "Ex: A"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipientData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
