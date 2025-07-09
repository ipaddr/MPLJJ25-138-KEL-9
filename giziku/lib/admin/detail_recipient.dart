import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_recipient.dart'; // **PERBAIKAN:** Import halaman edit yang benar

class RecipientDetailScreen extends StatefulWidget {
  final String recipientId;

  const RecipientDetailScreen({super.key, required this.recipientId});

  @override
  State<RecipientDetailScreen> createState() => _RecipientDetailScreenState();
}

class _RecipientDetailScreenState extends State<RecipientDetailScreen> {
  Map<String, dynamic>? _recipientData;
  bool _isLoading = true;
  String _appBarTitle = "Detail Penerima";

  @override
  void initState() {
    super.initState();
    _fetchRecipientData();
  }

  /// Mengambil data siswa dari Firestore berdasarkan ID
  Future<void> _fetchRecipientData() async {
    // Untuk memastikan data selalu terbaru setelah diedit
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('recipients')
              .doc(widget.recipientId)
              .get();

      if (docSnapshot.exists) {
        if (mounted) {
          setState(() {
            _recipientData = docSnapshot.data();
            _appBarTitle = _recipientData?['nama'] ?? 'Detail Penerima';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data penerima tidak ditemukan.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal mengambil data: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7EF),
      appBar: AppBar(
        backgroundColor: orangeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              if (_recipientData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // **PERBAIKAN:** Memanggil EditRecipientScreen
                    builder:
                        (context) => EditRecipientScreen(
                          recipientId: widget.recipientId,
                        ),
                  ),
                ).then((_) {
                  // Muat ulang data setelah kembali dari halaman edit
                  _fetchRecipientData();
                });
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recipientData == null
              ? const Center(child: Text("Tidak ada data untuk ditampilkan."))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailField(
                      label: "Name",
                      value: _recipientData!['nama'] ?? '',
                    ),
                    _buildDetailField(
                      label: "Date of Birth",
                      value: _recipientData!['tanggalLahir'] ?? '',
                    ),
                    _buildDetailField(
                      label: "Gender",
                      value: _recipientData!['jenisKelamin'] ?? '',
                    ),
                    _buildDetailField(
                      label: "Grade",
                      value: _recipientData!['grade'] ?? '',
                    ),
                    _buildDetailField(
                      label: "Class",
                      value: _recipientData!['kelas'] ?? '',
                    ),
                    _buildDetailField(
                      label: "Nomor Induk",
                      value: _recipientData!['studentId'] ?? '',
                    ),
                  ],
                ),
              ),
    );
  }

  /// Helper widget untuk menampilkan label dan nilainya
  Widget _buildDetailField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
