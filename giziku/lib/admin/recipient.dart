import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import 'profil_admin.dart';
import 'scanner.dart';

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

  final int _currentIndex = 2;
  String? _selectedGender;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  void _onTabTapped(int index) {
    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardAdmin();
        break;
      case 1:
        destination = const ScannerScreen();
        break;
      case 2:
        destination = const ProfileAdmin();
        break;
      default:
        destination = const DashboardAdmin();
    }

    if (index != _currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  Future<void> _saveRecipientData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _selectedGender == null ||
        _gradeController.text.isEmpty ||
        _classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('recipients').add({
        'userId': user.uid,
        'nama': _nameController.text,
        'tanggalLahir': _dobController.text,
        'jenisKelamin': _selectedGender,
        'grade': _gradeController.text,
        'kelas': _classController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data penerima berhasil disimpan")),
      );

      // Bersihkan form
      _nameController.clear();
      _dobController.clear();
      _gradeController.clear();
      _classController.clear();
      setState(() => _selectedGender = null);
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
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Data Penerima',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            buildLabel("Nama"),
            buildTextField(
              controller: _nameController,
              hintText: "Nama lengkap",
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
              hint: const Text("Pilih jenis kelamin"),
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
            buildLabel("Grade"),
            buildTextField(controller: _gradeController, hintText: "ex: 5"),
            buildLabel("Class"),
            buildTextField(controller: _classController, hintText: "ex: A"),
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
                  "Save",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: orangeColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
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
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
