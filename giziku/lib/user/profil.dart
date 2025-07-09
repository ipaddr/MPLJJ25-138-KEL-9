import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard.dart';
import 'notification.dart';
import 'progress.dart';
import 'edit_profile.dart';
import '../login/login.dart';
import 'menu_recomendation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 3;
  User? _currentUser;
  bool _isLoading = true;
  bool _isUploading = false;

  // State untuk data profil
  String _username = '';
  String _role = '';
  int _height = 0;
  int _weight = 0;
  String _fullName = '';
  String _bio = '';
  String? _photoURL;
  String _studentId = ''; // State baru untuk ID Siswa

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Fungsi untuk navigasi BottomNavigationBar
  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const MealsScreen();
        break;
      case 2:
        screen = const ProgressScreen();
        break;
      case 3:
        return; // Sudah di halaman profil
      default:
        screen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Mengambil data profil dari Firestore, termasuk ID Siswa
  Future<void> _loadProfileData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _username = data['username'] ?? '';
            _role = data['role'] ?? '';
            _height = (data['height'] ?? 0).toInt();
            _weight = (data['weight'] ?? 0).toInt();
            _fullName = data['full_name'] ?? '';
            _bio = data['bio'] ?? '';
            _photoURL = data['photoURL'];
            _studentId =
                data['studentId'] ?? 'Belum ditautkan'; // Ambil ID Siswa
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil data profil: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fungsi untuk memilih gambar dan mengunggahnya
  Future<void> _pickAndUploadImage() async {
    if (_currentUser == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (mounted) {
      setState(() {
        _isUploading = true;
      });
    }

    try {
      final File imageFile = File(image.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${_currentUser!.uid}.jpg');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'photoURL': url}, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _photoURL = url;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengunggah gambar: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Profil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileAvatar(),
            const SizedBox(height: 12),
            Text(
              _fullName.isNotEmpty ? _fullName : _username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              _bio.isNotEmpty ? _bio : _role,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _buildInfoCard(Icons.height, 'Tinggi', '$_height cm'),
                  const SizedBox(width: 12),
                  _buildInfoCard(Icons.monitor_weight, 'Berat', '$_weight kg'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoListItem(
              Icons.badge_outlined,
              'ID Siswa',
              _studentId,
            ), // Menampilkan ID Siswa
            _buildListItem(Icons.notifications, 'Notifikasi', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            }),
            _buildListItem(Icons.person_outline, 'Edit Profil', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              ).then(
                (_) => _loadProfileData(),
              ); // Muat ulang data setelah kembali
            }),
            _buildListItem(Icons.settings, 'Pengaturan'),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.black12,
            backgroundImage:
                _photoURL != null ? NetworkImage(_photoURL!) : null,
            child:
                _photoURL == null
                    ? const Icon(Icons.person, size: 50, color: Colors.black45)
                    : null,
          ),
          if (_isUploading)
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          if (!_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      backgroundColor: Colors.orange,
      type: BottomNavigationBarType.fixed,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progres'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// Helper widget untuk item yang bisa di-tap
  Widget _buildListItem(IconData icon, String label, [VoidCallback? onTap]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Helper widget baru untuk item info yang tidak bisa di-tap
  Widget _buildInfoListItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ),
    );
  }
}
