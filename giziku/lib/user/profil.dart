import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  String _username = '';
  String _role = '';
  int _height = 0;
  int _weight = 0;

  String _fullName = '';
  String _bio = '';

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
        return;
      default:
        screen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _loadProfileData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (doc.exists) {
        setState(() {
          _username = doc['username'] ?? '';
          _role = doc['role'] ?? '';
          _height = (doc['height'] ?? 0).toInt();
          _weight = (doc['weight'] ?? 0).toInt();

          _fullName = doc['full_name'] ?? '';
          _bio = doc['bio'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data profil: $e");

      setState(() {
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
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Profil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, size: 48, color: Colors.black45),
            ),
            const SizedBox(height: 12),
            Text(
              _fullName.isNotEmpty ? _fullName : _username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(_bio, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _buildInfoCard(Icons.height, 'Tinggi', _height.toString()),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    Icons.monitor_weight,
                    'Berat',
                    _weight.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  builder:
                      (context) => EditProfileScreen(
                        fullName: _fullName,
                        bio: _bio,
                        weight: _weight,
                        height: _height,
                      ),
                ),
              );
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progres',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
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

  Widget _buildListItem(IconData icon, String label, [VoidCallback? onTap]) {
    return Column(
      children: [
        Container(
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
        ),
      ],
    );
  }
}
