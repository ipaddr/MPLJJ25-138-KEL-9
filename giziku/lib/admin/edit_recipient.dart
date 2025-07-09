import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditRecipientScreen extends StatefulWidget {
  // Halaman ini wajib menerima ID siswa yang akan diedit
  final String recipientId;

  const EditRecipientScreen({super.key, required this.recipientId});

  @override
  State<EditRecipientScreen> createState() => _EditRecipientScreenState();
}

class _EditRecipientScreenState extends State<EditRecipientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _gradeController = TextEditingController();
  final _classController = TextEditingController();
  final _studentIdController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRecipientData();
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

  /// Memuat data siswa yang ada untuk diisi ke dalam form.
  Future<void> _loadRecipientData() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('recipients')
              .doc(widget.recipientId)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['nama'] ?? '';
        _studentIdController.text = data['studentId'] ?? '';
        _dobController.text = data['tanggalLahir'] ?? '';
        _selectedGender = data['jenisKelamin'];
        _gradeController.text = data['grade'] ?? '';
        _classController.text = data['kelas'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Menyimpan perubahan data ke Firestore.
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final dataToUpdate = {
      'nama': _nameController.text,
      'tanggalLahir': _dobController.text,
      'jenisKelamin': _selectedGender,
      'grade': _gradeController.text,
      'kelas': _classController.text,
      'studentId': _studentIdController.text,
    };

    try {
      await FirebaseFirestore.instance
          .collection('recipients')
          .doc(widget.recipientId)
          .update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan perubahan: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7EF),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Name"),
                      _buildTextField(
                        controller: _nameController,
                        hint: "Full Name",
                      ),
                      _buildLabel("Date of Birth"),
                      _buildDateField(),
                      _buildLabel("Gender"),
                      _buildGenderDropdown(),
                      _buildLabel("Grade"),
                      _buildTextField(
                        controller: _gradeController,
                        hint: "ex: 5",
                        keyboardType: TextInputType.number,
                      ),
                      _buildLabel("Class"),
                      _buildTextField(
                        controller: _classController,
                        hint: "ex: A",
                      ),
                      _buildLabel("Nomor Induk"),
                      _buildTextField(
                        controller: _studentIdController,
                        hint: "ex: 12345678",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isSaving
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _buildInputDecoration(hint: hint),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      decoration: _buildInputDecoration(
        hint: 'dd/mm/yyyy',
        icon: Icons.calendar_today,
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          _dobController.text = DateFormat('d MMMM yyyy').format(picked);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      hint: const Text("Choose your gender"),
      items:
          _genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
      onChanged: (val) => setState(() => _selectedGender = val),
      decoration: _buildInputDecoration(),
      validator: (value) {
        if (value == null) {
          return 'Please select a gender';
        }
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }
}
