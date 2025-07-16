import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CeklisAdminScreen extends StatefulWidget {
  final String? deliveryId;

  const CeklisAdminScreen({super.key, this.deliveryId});

  @override
  State<CeklisAdminScreen> createState() => _CeklisAdminScreenState();
}

class _CeklisAdminScreenState extends State<CeklisAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allRecipients = [];
  List<Map<String, dynamic>> _filteredRecipients = [];
  bool _isLoading = true;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _currentDeliveryId;

  @override
  void initState() {
    super.initState();
    _currentDeliveryId = widget.deliveryId;
    _fetchRecipients();
  }

  /// Mengambil data penerima dari Firestore
  Future<void> _fetchRecipients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Anda harus login sebagai admin.");
      }

      final recipientsSnapshot =
          await FirebaseFirestore.instance
              .collection('recipients')
              .where('userId', isEqualTo: user.uid)
              .get();

      List<Map<String, dynamic>> recipients = [];
      for (var doc in recipientsSnapshot.docs) {
        final data = doc.data();
        recipients.add({
          'id': doc.id,
          'studentId': data['studentId'] ?? '',
          'name': data['name'] ?? '',
          'class': data['class'] ?? '',
          'phone': data['phone'] ?? '',
        });
      }

      setState(() {
        _allRecipients = recipients;
        _filteredRecipients = recipients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Filter siswa berdasarkan pencarian
  void _filterRecipients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecipients = _allRecipients;
      } else {
        _filteredRecipients =
            _allRecipients.where((recipient) {
              final studentId = recipient['studentId'].toString().toLowerCase();
              final name = recipient['name'].toString().toLowerCase();
              final searchLower = query.toLowerCase();
              return studentId.contains(searchLower) ||
                  name.contains(searchLower);
            }).toList();
      }
    });
  }

  /// Cek apakah siswa sudah menerima makanan untuk delivery tertentu
  Future<bool> _checkIfAlreadyReceived(String studentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Gunakan deliveryId yang sudah ada atau buat berdasarkan tanggal
      final deliveryId =
          _currentDeliveryId ??
          '${user.uid}_${DateFormat('yyyy-MM-dd').format(DateTime.parse('$_selectedDate 00:00:00'))}';

      final deliveryRef = FirebaseFirestore.instance
          .collection('deliveries')
          .doc(deliveryId);

      final recipientQuery =
          await deliveryRef
              .collection('recipients')
              .where('studentId', isEqualTo: studentId)
              .where('status', isEqualTo: 'Received')
              .get();

      return recipientQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if already received: $e');
      return false;
    }
  }

  /// Menandai siswa telah menerima makanan
  Future<void> _markAsReceived(String studentId, String studentName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Anda harus login sebagai admin.");
      }

      // Cek apakah sudah menerima
      final alreadyReceived = await _checkIfAlreadyReceived(studentId);
      if (alreadyReceived) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$studentName sudah menerima makanan')),
        );
        return;
      }

      // Gunakan deliveryId yang sudah ada atau buat berdasarkan tanggal
      final deliveryId =
          _currentDeliveryId ??
          '${user.uid}_${DateFormat('yyyy-MM-dd').format(DateTime.parse('$_selectedDate 00:00:00'))}';

      final deliveryRef = FirebaseFirestore.instance
          .collection('deliveries')
          .doc(deliveryId);

      final deliveryDoc = await deliveryRef.get();
      if (!deliveryDoc.exists) {
        // Buat dokumen delivery baru jika belum ada
        await deliveryRef.set({
          'userId': user.uid,
          'deliveryDate': Timestamp.fromDate(
            DateTime.parse('$_selectedDate 00:00:00'),
          ),
          'totalMeals': 0,
          'receivedCount': 0,
          'surplusMeals': 0,
          'createdAt': Timestamp.now(),
        });
      }

      // Tambahkan siswa ke subcollection recipients
      await deliveryRef.collection('recipients').add({
        'studentId': studentId,
        'studentName': studentName,
        'status': 'Received',
        'timestamp': Timestamp.now(),
        'receivedAt': Timestamp.now(),
      });

      // Update receivedCount di dokumen delivery
      await deliveryRef.update({'receivedCount': FieldValue.increment(1)});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$studentName berhasil ditandai telah menerima makanan',
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Pilih tanggal untuk ceklis
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse('$_selectedDate 00:00:00'),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        // Reset currentDeliveryId karena tanggal berubah
        _currentDeliveryId = null;
      });
    }
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
          'Ceklis Penerima Makanan',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header dengan tanggal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.orange, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.parse('$_selectedDate 00:00:00'))}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _selectDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ubah Tanggal'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: _filterRecipients,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan NIS atau nama siswa...',
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.orange,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar siswa
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRecipients.isEmpty
                    ? const Center(
                      child: Text(
                        'Tidak ada siswa yang ditemukan',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredRecipients.length,
                      itemBuilder: (context, index) {
                        final recipient = _filteredRecipients[index];
                        return StudentCard(
                          studentId: recipient['studentId'],
                          name: recipient['name'],
                          className: recipient['class'],
                          phone: recipient['phone'],
                          onMarkReceived:
                              () => _markAsReceived(
                                recipient['studentId'],
                                recipient['name'],
                              ),
                          checkIfAlreadyReceived:
                              () => _checkIfAlreadyReceived(
                                recipient['studentId'],
                              ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatefulWidget {
  final String studentId;
  final String name;
  final String className;
  final String phone;
  final VoidCallback onMarkReceived;
  final Future<bool> Function() checkIfAlreadyReceived;

  const StudentCard({
    super.key,
    required this.studentId,
    required this.name,
    required this.className,
    required this.phone,
    required this.onMarkReceived,
    required this.checkIfAlreadyReceived,
  });

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  bool _isChecking = false;
  bool _alreadyReceived = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
    });

    final received = await widget.checkIfAlreadyReceived();

    setState(() {
      _alreadyReceived = received;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _alreadyReceived ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Info siswa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIS: ${widget.studentId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    'Kelas: ${widget.className}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (widget.phone.isNotEmpty)
                    Text(
                      'HP: ${widget.phone}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),

            // Status dan tombol
            Column(
              children: [
                if (_isChecking)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_alreadyReceived)
                  const Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(height: 4),
                      Text(
                        'Sudah Terima',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () async {
                      widget.onMarkReceived();
                      await Future.delayed(const Duration(seconds: 1));
                      _checkStatus(); // Refresh status
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Ceklis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
