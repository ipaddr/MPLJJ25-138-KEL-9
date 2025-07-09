import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'education.dart';
import 'history.dart';
import 'menu_recomendation.dart';
import 'progress.dart';
import 'profil.dart';
import 'chatbot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;

  // State untuk data dari Firebase
  User? _currentUser;
  bool _isLoading = true;
  String _username = 'User';
  Map<String, dynamic>? _todaysMenu;
  Map<String, dynamic>? _userTargets;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Mengambil data pengguna dan menu dari Firestore
  Future<void> _loadData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      setState(() {
        _errorMessage = "User not logged in.";
        _isLoading = false;
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Ambil data pengguna dan target nutrisinya
      final userDoc =
          await firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        _userTargets = userDoc.data();
        _username = _userTargets?['username'] ?? 'User';
      } else {
        throw Exception("User profile not found.");
      }

      // 2. Format tanggal hari ini
      final String formattedToday = DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.now());

      // 3. Ambil menu untuk hari ini
      final menuQuery =
          await firestore
              .collection('menus')
              .where('date', isEqualTo: formattedToday)
              .limit(1)
              .get();

      if (menuQuery.docs.isNotEmpty) {
        _todaysMenu = menuQuery.docs.first.data();
      } else {
        _todaysMenu = {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'deliveryTime': 'No schedule',
        };
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        screen = const ProfileScreen();
        break;
      default:
        screen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildReminderCard(),
                  _buildNutritionStatusCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.chat, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.orange,
      padding: const EdgeInsets.only(left: 16, top: 40, bottom: 12, right: 16),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang kembali',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                _username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    final nextMealTime = _todaysMenu?['deliveryTime'] ?? 'No schedule';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengingat Makan Harian',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Makan selanjutnya: Siang jam $nextMealTime',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStatusCard() {
    final num caloriesConsumed = _todaysMenu?['calories'] ?? 0;
    final num proteinConsumed = _todaysMenu?['protein'] ?? 0;
    final num carbsConsumed = _todaysMenu?['carbs'] ?? 0;

    final num targetCalories = _userTargets?['targetCalories'] ?? 2000;
    final num targetProtein = _userTargets?['targetProtein'] ?? 100;
    final num targetCarbs = _userTargets?['targetCarbs'] ?? 250;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Nutrisi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildProgressRow('Kalori', caloriesConsumed, targetCalories),
            _buildProgressRow('Protein', proteinConsumed, targetProtein),
            _buildProgressRow('Karbohidrat', carbsConsumed, targetCarbs),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, num consumed, num target) {
    final double progress = target > 0 ? (consumed / target) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickButton(
            icon: Icons.menu_book,
            label: 'Edukasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EducationScreen()),
              );
            },
          ),
          _buildQuickButton(
            icon: Icons.description,
            label: 'History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      backgroundColor: Colors.orange,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progres'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
