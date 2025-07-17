import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController openHoursController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessDescriptionController =
      TextEditingController();

  bool _isLoading = true;
  DocumentReference? _profileRef;

  @override
  void initState() {
    super.initState();
    _initializeProfileRef();
  }

  /// Inisialisasi referensi profil berdasarkan user yang sedang login
  void _initializeProfileRef() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _profileRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid);
      _loadProfileData();
    } else {
      // Jika tidak ada user yang login, redirect ke login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Mengambil data profil dari Firestore untuk diisi ke dalam form.
  Future<void> _loadProfileData() async {
    if (_profileRef == null) return;

    try {
      final snapshot = await _profileRef!.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        // Menggunakan field names yang konsisten dengan ProfileScreen
        businessNameController.text =
            data['businessName'] ?? data['username'] ?? data['name'] ?? '';
        openHoursController.text =
            data['openHours'] ?? data['operatingHours'] ?? '';
        locationController.text = data['location'] ?? data['address'] ?? '';
        phoneNumberController.text =
            data['phoneNumber'] ?? data['phone'] ?? data['contactNumber'] ?? '';
        businessDescriptionController.text =
            data['businessDescription'] ?? data['description'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat profil: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menyimpan perubahan ke Firestore.
  Future<void> _saveChanges() async {
    if (_profileRef == null) return;

    if (businessNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama Bisnis tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menggunakan field names yang konsisten
      await _profileRef!.set({
        'businessName': businessNameController.text,
        'openHours': openHoursController.text,
        'location': locationController.text,
        'phoneNumber': phoneNumberController.text,
        'businessDescription': businessDescriptionController.text,
        'updatedAt': FieldValue.serverTimestamp(), // Tambahkan timestamp
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!')),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan perubahan: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    businessNameController.dispose();
    openHoursController.dispose();
    locationController.dispose();
    phoneNumberController.dispose();
    businessDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        title: const Text('Edit Profile'),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Business Name',
                      hintText: 'Example: Healthy Kitchen',
                      controller: businessNameController,
                    ),
                    _buildTextField(
                      label: 'Open Hours',
                      hintText: 'Example: 08:00 - 20:00',
                      controller: openHoursController,
                    ),
                    _buildTextField(
                      label: 'Location',
                      hintText: 'Example: Padang, Indonesia',
                      controller: locationController,
                    ),
                    _buildTextField(
                      label: 'Phone Number',
                      hintText: 'Example: +62 8123-124-2346',
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      label: 'Business Description',
                      hintText: 'Example: Trusted Healthy Food Supplier',
                      controller: businessDescriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF9800),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
