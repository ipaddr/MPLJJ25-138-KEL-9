import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'delivery.dart';
import 'menu.dart';
import 'profile.dart';
import 'chatbot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Daftar layar untuk Bottom Navigation
  final List<Widget> _screens = const [
    DashboardHomeContent(),
    DeliveryScreen(),
    MenuScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      // AppBar hanya ditampilkan di halaman Home
      appBar:
          _currentIndex == 0
              ? AppBar(
                backgroundColor: const Color(0xFFFFA726),
                title: const Text(
                  'Dashboard Distribusi',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
              )
              : null,
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
        },
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        backgroundColor: Colors.orange,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Delivery',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Widget untuk konten utama halaman Dashboard (Home)
class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan StreamBuilder untuk mendapatkan data pengiriman secara real-time
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('deliveries').snapshots(),
      builder: (context, snapshot) {
        // Tampilkan loading indicator saat data sedang diambil
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Tampilkan pesan jika tidak ada data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada data pengiriman."));
        }

        // Proses data jika berhasil didapatkan
        int totalMeals = 0;
        int pendingDeliveries = 0;
        int completedDeliveries = 0;
        // int failedDeliveries = 0; // Anda bisa menambahkan logika ini jika ada status 'Failed'

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Akumulasi total makanan
          totalMeals += (data['numberOfMeals'] as num? ?? 0).toInt();

          // Hitung status pengiriman
          if (data['status'] == 'Pending') {
            pendingDeliveries++;
          } else if (data['status'] == 'Completed') {
            completedDeliveries++;
          }
        }

        // Tampilkan UI dengan data yang sudah diproses
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: statCard('Total Makanan', totalMeals.toString()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statCard('Waktu Rata-rata\nPengiriman', '38m'),
                  ), // Data statis
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFA726)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skor Kepuasan', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Text(
                          '4.6',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.star_half, color: Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Statistik Pengiriman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              statBox(
                color: Colors.blue,
                count: pendingDeliveries.toString(),
                label: 'Dalam Pengiriman',
              ),
              statBox(
                color: Colors.green,
                count: completedDeliveries.toString(),
                label: 'Selesai',
              ),
              statBox(
                color: Colors.red,
                count: '0',
                label: 'Gagal',
              ), // Data statis
            ],
          ),
        );
      },
    );
  }

  // Helper widget untuk kartu statistik utama
  Widget statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFA726)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk baris statistik pengiriman
  Widget statBox({
    required Color color,
    required String count,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
