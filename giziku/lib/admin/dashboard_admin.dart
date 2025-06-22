// lib/admin/dashboard_admin.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'daftar_recipient.dart';
import 'profil_admin.dart';
import 'scanner.dart';
import 'laporan.dart';
import 'chatbot.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _currentIndex = 0;

  String _schoolName = '';
  bool _isLoading = true;

  Stream<QuerySnapshot>?
  _allRecipientsStream; // Stream untuk total penerima (SEMUA)
  Stream<QuerySnapshot>?
  _distributedRecipientsStream; // Stream untuk penerima yang sudah TERDISTRIBUSI

  @override
  void initState() {
    super.initState();
    _fetchSchoolData();
    _setupRecipientStreams();
  }

  void _setupRecipientStreams() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Stream untuk MENGHITUNG SEMUA PENERIMA
      _allRecipientsStream =
          FirebaseFirestore.instance
              .collection('recipients')
              .where('userId', isEqualTo: user.uid)
              .snapshots();

      // Stream untuk MENGHITUNG PENERIMA YANG SUDAH TERDISTRIBUSI (dicentang)
      _distributedRecipientsStream =
          FirebaseFirestore.instance
              .collection('recipients')
              .where('userId', isEqualTo: user.uid)
              .where(
                'statusDistribusi',
                isEqualTo: 'terdistribusi',
              ) // Filter penting
              .snapshots();
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    Widget screen;
    switch (index) {
      case 0:
        screen = const DashboardAdmin();
        break;
      case 1:
        screen = const ScannerScreen();
        break;
      case 2:
        screen = const ProfileAdmin();
        break;
      default:
        screen = const DashboardAdmin();
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  Future<void> _fetchSchoolData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _schoolName = 'User tidak login';
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      setState(() {
        _schoolName =
            userDoc.exists && userDoc.data()!.containsKey('sekolah')
                ? userDoc['sekolah']
                : 'Nama Sekolah';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal mengambil data sekolah: $e");
      setState(() {
        _schoolName = 'Gagal mengambil data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7EF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: orangeColor,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(Icons.school, size: 48, color: Colors.black),
                  const SizedBox(height: 8),
                  const Text(
                    "Selamat Datang Admin",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      )
                      : Text(
                        _schoolName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistik box (Disimplifikasi menjadi 3 statistik: Total Penerima, Total Distribusi, Sisa)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Baris 1: Total Penerima dan Total Distribusi
                  Row(
                    children: [
                      // Stat: Total Penerima (Semua yang diinput)
                      user == null
                          ? const StatBox(label: "Total Penerima", value: "0")
                          : StreamBuilder<QuerySnapshot>(
                            stream: _allRecipientsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const StatBox(
                                  label: "Total Penerima",
                                  value: "...",
                                );
                              }
                              if (snapshot.hasError) {
                                return const StatBox(
                                  label: "Total Penerima",
                                  value: "Error",
                                );
                              }
                              final total = snapshot.data?.docs.length ?? 0;
                              return StatBox(
                                label: "Total Penerima",
                                value: total.toString(),
                              );
                            },
                          ),
                      const SizedBox(width: 12),
                      // Stat: Total Distribusi (yang sudah dicentang)
                      user == null
                          ? const StatBox(label: "Total Distribusi", value: "0")
                          : StreamBuilder<QuerySnapshot>(
                            stream: _distributedRecipientsStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const StatBox(
                                  label: "Total Distribusi",
                                  value: "...",
                                );
                              }
                              if (snapshot.hasError) {
                                return const StatBox(
                                  label: "Total Distribusi",
                                  value: "Error",
                                );
                              }
                              final distributedTotal =
                                  snapshot.data?.docs.length ?? 0;
                              return StatBox(
                                label: "Total Distribusi",
                                value: distributedTotal.toString(),
                              );
                            },
                          ),
                    ],
                  ),
                  const SizedBox(height: 12), // Spasi antar baris statistik
                  // Baris 2: Sisa (hitung dari kedua stream)
                  Row(
                    children: [
                      user == null
                          ? const StatBox(label: "Sisa", value: "0")
                          : StreamBuilder<QuerySnapshot>(
                            stream: _allRecipientsStream, // Ambil total semua
                            builder: (context, allSnapshot) {
                              if (allSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const StatBox(
                                  label: "Sisa",
                                  value: "...",
                                );
                              }
                              if (allSnapshot.hasError) {
                                return const StatBox(
                                  label: "Sisa",
                                  value: "Error",
                                );
                              }
                              final totalAll =
                                  allSnapshot.data?.docs.length ?? 0;

                              return StreamBuilder<QuerySnapshot>(
                                stream:
                                    _distributedRecipientsStream, // Ambil total terdistribusi
                                builder: (context, distributedSnapshot) {
                                  if (distributedSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const StatBox(
                                      label: "Sisa",
                                      value: "...",
                                    );
                                  }
                                  if (distributedSnapshot.hasError) {
                                    return const StatBox(
                                      label: "Sisa",
                                      value: "Error",
                                    );
                                  }
                                  final totalDistributed =
                                      distributedSnapshot.data?.docs.length ??
                                      0;
                                  final remaining = totalAll - totalDistributed;
                                  return StatBox(
                                    label: "Sisa",
                                    value: remaining.toString(),
                                  );
                                },
                              );
                            },
                          ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tombol aksi (tetap sama)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      icon: Icons.groups,
                      label: "Data Penerima",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DaftarSiswaScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      icon: Icons.receipt_long,
                      label: "Laporan\nDistribusi",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DistributionReportScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: orangeColor,
        selectedItemColor: Colors.black,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// StatBox dan ActionButton tetap sama
class StatBox extends StatelessWidget {
  final String label;
  final String value;

  const StatBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
