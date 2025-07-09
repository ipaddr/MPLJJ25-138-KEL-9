import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<Map<String, dynamic>>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  /// Mengambil data riwayat dari Firestore.
  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Anda harus login untuk melihat riwayat.");
    }

    // 1. Dapatkan studentId dari profil pengguna yang sedang login.
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (!userDoc.exists || userDoc.data()?['studentId'] == null) {
      throw Exception("Profil siswa tidak tertaut dengan akun ini.");
    }
    final studentId = userDoc.data()!['studentId'];

    // 2. **PERBAIKAN:** Menambahkan orderBy agar cocok dengan indeks yang ada.
    final historyQuery =
        await FirebaseFirestore.instance
            .collectionGroup('recipients')
            .where('studentId', isEqualTo: studentId)
            .orderBy('timestamp', descending: true) // <-- Tambahkan ini
            .get();

    // 3. Ambil data tanggal dari dokumen pengiriman induk untuk setiap riwayat.
    // Karena sudah diurutkan dari database, kita tidak perlu sorting lagi di sini.
    List<Map<String, dynamic>> historyList = [];
    for (var doc in historyQuery.docs) {
      final deliveryDocRef = doc.reference.parent.parent;
      if (deliveryDocRef != null) {
        final deliveryDoc = await deliveryDocRef.get();
        if (deliveryDoc.exists) {
          // Gabungkan data riwayat dengan data pengiriman.
          historyList.add({
            'status': doc.data()['status'],
            'deliveryData': deliveryDoc.data(),
          });
        }
      }
    }

    return historyList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Riwayat', style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Tampilkan pesan error yang lebih informatif
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat.'));
          }

          final historyItems = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              final item = historyItems[index];
              final deliveryData =
                  item['deliveryData'] as Map<String, dynamic>?;

              final Timestamp timestamp =
                  deliveryData?['deliveryDate'] ?? Timestamp.now();
              final String date = DateFormat(
                'EEEE, d MMMM yyyy',
              ).format(timestamp.toDate());
              final bool isCompleted = item['status'] == 'Received';

              return HistoryCard(
                date: date,
                meal: 'Makan Siang', // Anda bisa membuat ini dinamis jika perlu
                isCompleted: isCompleted,
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String date;
  final String meal;
  final bool isCompleted;

  const HistoryCard({
    super.key,
    required this.date,
    required this.meal,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(meal, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
