import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import '../login/login.dart';
import 'scanner.dart';
import 'edit_profiladmin.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  final int _currentIndex = 2;

  String _schoolName = '';
  String _npsn = '';
  String _responsible = '';
  String _position = '';
  String _address = '';
  String _students = '';

  bool _isLoading = true;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const DashboardAdmin();
        break;
      case 1:
        screen = const ScannerScreen();
        break;
      case 2:
        return;
      default:
        screen = const DashboardAdmin();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _schoolName =
              (data['sekolah'] ?? 'Nama sekolah tidak tersedia').toString();
          _npsn = (data['npsn'] ?? '-').toString();
          _responsible = (data['responsible'] ?? '-').toString();
          _position = (data['position'] ?? '-').toString();
          _address = (data['address'] ?? '-').toString();
          _students = (data['students']?.toString() ?? '-');
          _isLoading = false;
        });
      } else {
        setState(() {
          _schoolName = 'Data tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _schoolName = 'Gagal memuat data';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);
    const bgColor = Color(0xFFFEF7EF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: orangeColor,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text('Profil', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileAdmin()),
                );
              },
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Icon(Icons.school, size: 60),
                    const SizedBox(height: 8),
                    Text(
                      _schoolName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildInfoTile(Icons.format_list_numbered, 'NPSN', _npsn),
                    buildInfoTile(
                      Icons.person,
                      'Penanggung Jawab',
                      _responsible,
                    ),
                    buildInfoTile(Icons.badge, 'Jabatan', _position),
                    buildInfoTile(Icons.location_on, 'Alamat', _address),
                    buildInfoTile(Icons.people, 'Jumlah Siswa', _students),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.black),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  Widget buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
