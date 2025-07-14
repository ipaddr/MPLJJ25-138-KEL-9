import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipientDataScreen extends StatefulWidget {
  const RecipientDataScreen({super.key});

  @override
  State<RecipientDataScreen> createState() => _RecipientDataScreenState();
}

class _RecipientDataScreenState extends State<RecipientDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _gradeController = TextEditingController();
  final _classController = TextEditingController();
  final _studentIdController = TextEditingController();

  String? _selectedGender;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];
  String? _schoolName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchSchoolName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _gradeController.dispose();
    _classController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  /// **LOGIKA BARU:** Mengambil nama sekolah dari profil admin
  Future<void> _fetchSchoolName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (mounted && userDoc.exists) {
        setState(() {
          _schoolName = userDoc.data()?['sekolah'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching school name: $e");
    }
  }

  Future<void> _saveRecipientData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_schoolName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data sekolah admin tidak ditemukan.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // **PERBAIKAN:** Menyimpan 'schoolName' bersama data siswa
      await FirebaseFirestore.instance.collection('recipients').add({
        'userId': user.uid,
        'nama': _nameController.text,
        'tanggalLahir': _dobController.text,
        'jenisKelamin': _selectedGender,
        'grade': _gradeController.text,
        'kelas': _classController.text,
        'studentId': _studentIdController.text,
        'schoolName': _schoolName, // <-- Field penting ditambahkan di sini
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data penerima berhasil disimpan")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7EF),
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: const Text(
          'Tambah Data Penerima',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ... (UI form Anda tetap sama)
              buildLabel("Nama"),
              buildTextField(
                controller: _nameController,
                hintText: "Nama Lengkap",
              ),
              buildLabel("Nomor Induk Siswa"),
              buildTextField(
                controller: _studentIdController,
                hintText: "Contoh: 12345678",
                keyboardType: TextInputType.number,
              ),
              // ... sisa form
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecipientData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Helper widget buildLabel dan buildTextField tetap sama)
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) => value!.isEmpty ? 'Field ini tidak boleh kosong' : null,
    );
  }
}
