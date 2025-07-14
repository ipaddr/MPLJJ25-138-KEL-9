import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipient.dart';
import 'detail_recipient.dart';
import 'edit_recipient.dart';

class DaftarSiswaScreen extends StatefulWidget {
  // ID ini opsional. Jika ada, berarti halaman ini dalam mode "memilih untuk ceklis".
  final String? deliveryId;

  const DaftarSiswaScreen({super.key, this.deliveryId});

  @override
  State<DaftarSiswaScreen> createState() => _DaftarSiswaScreenState();
}

class _DaftarSiswaScreenState extends State<DaftarSiswaScreen> {
  // Menentukan apakah halaman ini dalam mode memilih atau mode biasa
  bool get _isSelectionMode => widget.deliveryId != null;

  /// Fungsi baru untuk menghapus data siswa
  Future<void> _deleteRecipient(String docId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Data'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus data siswa ini? Aksi ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('recipients')
            .doc(docId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data siswa berhasil dihapus.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
        }
      }
    }
  }

  /// Fungsi yang dijalankan saat nama siswa di-tap.
  Future<void> _handleRecipientTap(
    String studentDocId,
    Map<String, dynamic> studentData,
  ) async {
    if (_isSelectionMode) {
      // Jika dalam mode memilih, tambahkan siswa ke daftar hadir
      final deliveryRecipientRef = FirebaseFirestore.instance
          .collection('deliveries')
          .doc(widget.deliveryId!)
          .collection('recipients')
          .doc(studentDocId);

      await deliveryRecipientRef.set({
        'studentName': studentData['nama'],
        'class': "${studentData['grade']}${studentData['kelas']}",
        'status': 'Absent', // Status awal saat ditambahkan
        'studentId':
            studentData['studentId'], // Menggunakan studentId dari data master
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${studentData['nama']} telah ditambahkan ke daftar hadir.',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Jika mode biasa, buka halaman detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RecipientDetailScreen(recipientId: studentDocId),
        ),
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
        title: Text(
          _isSelectionMode ? 'Pilih Siswa' : 'Data Penerima',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body:
          user == null
              ? const Center(child: Text("Silakan login untuk melihat data."))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('recipients')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('nama', descending: false)
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
                      final doc = recipients[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          onTap: () => _handleRecipientTap(doc.id, data),
                          title: Text(
                            data['nama'] ?? 'Nama Tidak Ada',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Kelas ${data['grade'] ?? ''}${data['kelas'] ?? ''}",
                          ),
                          // **PERBAIKAN:** Mengganti Checkbox dengan PopupMenuButton
                          trailing:
                              _isSelectionMode
                                  ? const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.orange,
                                  )
                                  : PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    EditRecipientScreen(
                                                      recipientId: doc.id,
                                                    ),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        _deleteRecipient(doc.id);
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                  ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton:
          _isSelectionMode
              ? null // Sembunyikan tombol tambah jika dalam mode memilih
              : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipientDataScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.orange,
                child: const Icon(Icons.add, color: Colors.white),
              ),
    );
  }
}
