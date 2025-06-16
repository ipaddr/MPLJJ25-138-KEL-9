import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String fullName;
  final String bio;
  final int weight;
  final int height;

  const EditProfileScreen({
    super.key,
    required this.fullName,
    required this.bio,
    required this.weight,
    required this.height,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController bioController;
  late TextEditingController weightController;
  late TextEditingController heightController;

  User? _currentUser;

  @override
  void initState() {
    super.initState();

    _currentUser = FirebaseAuth.instance.currentUser;

    fullNameController = TextEditingController(text: widget.fullName);
    bioController = TextEditingController(text: widget.bio);
    weightController = TextEditingController(text: widget.weight.toString());
    heightController = TextEditingController(text: widget.height.toString());
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'full_name': fullNameController.text,
            'bio': bioController.text,
            'height': int.tryParse(heightController.text) ?? 0,
            'weight': int.tryParse(weightController.text) ?? 0,
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    bioController.dispose();
    weightController.dispose();
    heightController.dispose();

    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.black),
              ),
              const SizedBox(height: 16),
              _buildTextField(fullNameController, 'Full Name'),
              const SizedBox(height: 10),
              _buildTextField(bioController, 'Bio'),
              const SizedBox(height: 10),
              _buildTextField(heightController, 'Height'),
              const SizedBox(height: 10),
              _buildTextField(weightController, 'Weight'),
              const SizedBox(height: 24),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(height: 12),
              // Save Change Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save Change',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
