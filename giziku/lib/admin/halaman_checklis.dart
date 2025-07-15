import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'daftar_recipient.dart'; // Sesuaikan path ke halaman daftar master siswa

class DeliveryChecklistScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryChecklistScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryChecklistScreen> createState() =>
      _DeliveryChecklistScreenState();
}

class _DeliveryChecklistScreenState extends State<DeliveryChecklistScreen> {
  bool _isAdding = false;
  bool _isSubmitting = false; // State baru untuk proses submit
  String? _schoolName;
  String? _deliveryDate;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryInfo();
  }

  /// Mengambil info pengiriman, seperti nama sekolah dan tanggal.
  Future<void> _fetchDeliveryInfo() async {
    try {
      final deliveryDoc =
          await FirebaseFirestore.instance
              .collection('deliveries')
              .doc(widget.deliveryId)
              .get();
      if (deliveryDoc.exists) {
        final data = deliveryDoc.data();
        if (mounted) {
          setState(() {
            _schoolName = data?['schoolName'];
            if (data?['deliveryDate'] != null) {
              final timestamp = data!['deliveryDate'] as Timestamp;
              _deliveryDate = DateFormat(
                'd MMMM yyyy',
              ).format(timestamp.toDate());
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching delivery info: $e");
    }
  }

  /// Mengisi daftar hadir untuk pengiriman ini dari data master siswa.
  Future<void> _populateStudentList() async {
    if (_schoolName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data sekolah belum dimuat.")),
      );
      return;
    }
    setState(() => _isAdding = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();

      final masterRecipients =
          await firestore
              .collection('recipients')
              .where('schoolName', isEqualTo: _schoolName)
              .get();

      if (masterRecipients.docs.isEmpty) {
        throw Exception(
          "Tidak ada data siswa master yang ditemukan untuk sekolah ini.",
        );
      }

      final deliveryRecipientsRef = firestore
          .collection('deliveries')
          .doc(widget.deliveryId)
          .collection('recipients');

      for (var studentDoc in masterRecipients.docs) {
        final studentData = studentDoc.data();
        final studentId = studentDoc.id;

        batch.set(deliveryRecipientsRef.doc(studentId), {
          'studentName': studentData['nama'],
          'class': "${studentData['grade']}${studentData['kelas']}",
          'status': 'Absent', // Status default
          'studentId': studentData['studentId'],
        });
      }

      await batch.commit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengisi daftar: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  /// **FUNGSI BARU:** Menghitung dan menyimpan statistik ke dokumen pengiriman
  Future<void> _submitChecklist() async {
    setState(() => _isSubmitting = true);

    try {
      final recipientsRef = FirebaseFirestore.instance
          .collection('deliveries')
          .doc(widget.deliveryId)
          .collection('recipients');

      final snapshot = await recipientsRef.get();

      int receivedCount = 0;
      for (var doc in snapshot.docs) {
        if (doc.data()['status'] == 'Received') {
          receivedCount++;
        }
      }

      // Update dokumen pengiriman utama dengan data statistik
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(widget.deliveryId)
          .update({
            'receivedCount': receivedCount,
            'absentCount': snapshot.docs.length - receivedCount,
            'totalRecipients': snapshot.docs.length,
            'isFinalized': true, // Tandai bahwa ceklis sudah selesai
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Laporan kehadiran berhasil disubmit!")),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal submit: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipientsRef = FirebaseFirestore.instance
        .collection('deliveries')
        .doc(widget.deliveryId)
        .collection('recipients');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: Column(
          children: [
            Text(_schoolName ?? 'Daftar Kehadiran'),
            if (_deliveryDate != null)
              Text(
                _deliveryDate!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.orange,
        actions: [
          Tooltip(
            message: 'Kelola Daftar Siswa',
            child: IconButton(
              icon: const Icon(Icons.people_alt_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DaftarSiswaScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: recipientsRef.orderBy('studentName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.playlist_add_check,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daftar kehadiran untuk hari ini kosong.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Isi Daftar Siswa Hari Ini'),
                      onPressed: _isAdding ? null : _populateStudentList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool hasReceived = data['status'] == 'Received';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(data['studentName'] ?? 'No Name'),
                  subtitle: Text("Kelas ${data['class'] ?? ''}"),
                  trailing: Checkbox(
                    value: hasReceived,
                    onChanged: (value) {
                      recipientsRef.doc(doc.id).update({
                        'status': value! ? 'Received' : 'Absent',
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // **UI BARU:** Menambahkan tombol Submit di bagian bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitChecklist,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    'Submit Kehadiran',
                    style: TextStyle(fontSize: 16),
                  ),
        ),
      ),
    );
  }
}
