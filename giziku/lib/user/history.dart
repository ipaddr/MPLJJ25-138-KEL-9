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

  /// Mengambil data riwayat dari Firestore berdasarkan studentId user
  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Anda harus login untuk melihat riwayat.");
    }

    try {
      // 1. Dapatkan studentId dari profil pengguna yang sedang login
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists || userDoc.data()?['studentId'] == null) {
        throw Exception("Profil siswa tidak tertaut dengan akun ini.");
      }

      final studentId = userDoc.data()!['studentId'];

      // 2. Cari semua delivery yang mengandung studentId ini
      final deliveriesSnapshot =
          await FirebaseFirestore.instance
              .collection('deliveries')
              .orderBy('deliveryDate', descending: true)
              .get();

      List<Map<String, dynamic>> historyList = [];

      // 3. Periksa setiap delivery untuk mencari recipients yang cocok
      for (var deliveryDoc in deliveriesSnapshot.docs) {
        final deliveryData = deliveryDoc.data();

        // Cari di subcollection recipients
        final recipientsSnapshot =
            await deliveryDoc.reference
                .collection('recipients')
                .where('studentId', isEqualTo: studentId)
                .get();

        // Jika ditemukan, tambahkan ke historyList
        for (var recipientDoc in recipientsSnapshot.docs) {
          final recipientData = recipientDoc.data();

          historyList.add({
            'deliveryId': deliveryDoc.id,
            'deliveryDate': deliveryData['deliveryDate'],
            'studentId': recipientData['studentId'],
            'studentName': recipientData['studentName'],
            'status': recipientData['status'],
            'receivedAt': recipientData['receivedAt'],
            'timestamp': recipientData['timestamp'],
          });
        }
      }

      // 4. Urutkan berdasarkan tanggal terbaru
      historyList.sort((a, b) {
        Timestamp timeA = a['deliveryDate'] ?? Timestamp.now();
        Timestamp timeB = b['deliveryDate'] ?? Timestamp.now();
        return timeB.compareTo(timeA); // Terbaru di atas
      });

      return historyList;
    } catch (e) {
      print('Error fetching history: $e');
      rethrow;
    }
  }

  /// Refresh data riwayat
  void _refreshHistory() {
    setState(() {
      _historyFuture = _fetchHistory();
    });
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
        title: const Text(
          'Riwayat Penerimaan Makanan',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat riwayat...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshHistory,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat penerimaan makanan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final historyItems = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshHistory();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];

                final Timestamp deliveryDate =
                    item['deliveryDate'] ?? Timestamp.now();
                final Timestamp? receivedAt = item['receivedAt'];

                final String dateString = DateFormat(
                  'EEEE, d MMMM yyyy',
                ).format(deliveryDate.toDate());
                final String timeString =
                    receivedAt != null
                        ? DateFormat('HH:mm').format(receivedAt.toDate())
                        : '';

                final bool isReceived = item['status'] == 'Received';

                return HistoryCard(
                  date: dateString,
                  time: timeString,
                  meal: 'Makan Siang Gratis',
                  studentName: item['studentName'] ?? '',
                  isReceived: isReceived,
                  deliveryId: item['deliveryId'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String date;
  final String time;
  final String meal;
  final String studentName;
  final bool isReceived;
  final String deliveryId;

  const HistoryCard({
    super.key,
    required this.date,
    required this.time,
    required this.meal,
    required this.studentName,
    required this.isReceived,
    required this.deliveryId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isReceived ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      if (time.isNotEmpty)
                        Text(
                          'Pukul $time',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isReceived ? Icons.check_circle : Icons.cancel,
                  color: isReceived ? Colors.green : Colors.red,
                  size: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (studentName.isNotEmpty)
              Text(
                'Penerima: $studentName',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isReceived
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isReceived ? 'Sudah Diterima' : 'Belum Diterima',
                style: TextStyle(
                  color: isReceived ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
