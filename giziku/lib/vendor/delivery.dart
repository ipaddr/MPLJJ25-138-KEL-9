import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_delivery.dart';

/// Enum untuk merepresentasikan status pengiriman di UI.
enum DeliveryStatus { inProgress, completed }

/// Halaman utama yang menampilkan daftar pengiriman.
class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  /// Fungsi untuk navigasi ke halaman tambah pengiriman.
  void _navigateToAddDelivery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDeliveryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text('Deliveries'),
        backgroundColor: const Color(0xFFFF9800),
        automaticallyImplyLeading: false, // Menghilangkan tombol kembali
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mendengarkan perubahan pada koleksi 'deliveries' di Firestore,
        // diurutkan berdasarkan yang terbaru.
        stream:
            FirebaseFirestore.instance
                .collection('deliveries')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          // Menampilkan indikator loading saat data sedang diambil.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Menampilkan pesan jika terjadi error saat mengambil data.
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }

          // Menampilkan pesan jika tidak ada data pengiriman.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pengiriman.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          // Jika data berhasil diambil, tampilkan dalam bentuk daftar.
          final deliveries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final deliveryDoc = deliveries[index];
              final String documentId = deliveryDoc.id;

              // Mapping data dari Firestore ke variabel lokal.
              final String schoolName = deliveryDoc['schoolName'];
              final String deliveryTime = deliveryDoc['deliveryTime'];
              final int meals = deliveryDoc['numberOfMeals'];
              final String statusString = deliveryDoc['status'];

              // Konversi status dari String menjadi Enum.
              final DeliveryStatus status =
                  statusString == 'Pending'
                      ? DeliveryStatus.inProgress
                      : DeliveryStatus.completed;

              // Mengembalikan widget card untuk setiap item pengiriman.
              return DeliveryCard(
                documentId: documentId,
                time: deliveryTime,
                location: schoolName,
                meals: meals,
                status: status,
              );
            },
          );
        },
      ),
      // Tombol di bagian bawah untuk menambah pengiriman baru.
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        color: const Color(0xFFFFF6ED),
        child: ElevatedButton(
          onPressed: () => _navigateToAddDelivery(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add Delivery',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan satu item pengiriman dalam daftar.
class DeliveryCard extends StatelessWidget {
  final String documentId;
  final String time;
  final String location;
  final int meals;
  final DeliveryStatus status;

  const DeliveryCard({
    super.key,
    required this.documentId,
    required this.time,
    required this.location,
    required this.meals,
    required this.status,
  });

  /// Fungsi untuk mengubah status pengiriman di Firestore menjadi 'Completed'.
  Future<void> _markAsCompleted() async {
    try {
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(documentId)
          .update({'status': 'Completed'});
    } catch (e) {
      // Anda bisa menambahkan notifikasi error jika diperlukan.
      print("Gagal mengubah status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Aksi saat item di-tap.
      onTap: () {
        // Fungsi hanya akan dijalankan jika status masih 'inProgress'.
        if (status == DeliveryStatus.inProgress) {
          _markAsCompleted();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.orangeAccent, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            // Tampilan kondisional berdasarkan status pengiriman.
            if (status == DeliveryStatus.inProgress)
              // Menampilkan titik hijau jika status 'inProgress'.
              const Icon(Icons.circle, color: Colors.green, size: 12)
            else
              // Menampilkan jumlah makanan jika status 'completed'.
              Text('$meals meals', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
