// lib/daftar_recipient.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipient.dart';
import 'detail_recipient.dart'; // Import halaman detail

class DaftarSiswaScreen extends StatefulWidget {
  const DaftarSiswaScreen({super.key});

  @override
  State<DaftarSiswaScreen> createState() => _DaftarSiswaScreenState();
}

class _DaftarSiswaScreenState extends State<DaftarSiswaScreen> {
  // Fungsi untuk memperbarui status distribusi di Firestore
  Future<void> _updateDistributionStatus(
    String docId,
    bool isDistributed,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('recipients')
          .doc(docId)
          .update({
            'statusDistribusi':
                isDistributed ? 'terdistribusi' : 'belum_terdistribusi',
            'tanggalDistribusi':
                isDistributed ? FieldValue.serverTimestamp() : null,
          });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status distribusi berhasil diperbarui.')),
      );
    } catch (e) {
      debugPrint("Error updating distribution status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status distribusi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE3),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Data Penerima',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body:
          user == null
              ? const Center(
                child: Text("Silakan login untuk melihat data penerima."),
              )
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('recipients')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data penerima.'),
                    );
                  }

                  final recipients = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: recipients.length,
                    itemBuilder: (context, index) {
                      final docId = recipients[index].id; // Dapatkan ID dokumen
                      final data =
                          recipients[index].data() as Map<String, dynamic>;
                      final bool isDistributed =
                          (data['statusDistribusi'] == 'terdistribusi');

                      // **PERBAIKAN:** Membungkus Card dengan InkWell untuk navigasi
                      return InkWell(
                        onTap: () {
                          // Navigasi ke halaman detail dengan mengirim ID dokumen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      RecipientDetailScreen(recipientId: docId),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['nama'] ?? 'Nama Tidak Ada',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        data['jenisKelamin'] ??
                                            'Jenis Kelamin Tidak Ada',
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  data['grade'] ?? 'Grade Tidak Ada',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  data['kelas'] ?? 'Kelas Tidak Ada',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Checkbox(
                                  value: isDistributed,
                                  onChanged: (bool? newValue) {
                                    if (newValue != null) {
                                      _updateDistributionStatus(
                                        docId,
                                        newValue,
                                      );
                                    }
                                  },
                                  activeColor: Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipientDataScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Tambah',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
