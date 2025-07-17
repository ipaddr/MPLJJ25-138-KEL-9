import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'form_delivery.dart';

enum DeliveryStatus { inProgress, completed }

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  void _navigateToAddDelivery(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDeliveryScreen()),
    );
    // Data akan otomatis refresh karena menggunakan StreamBuilder
    // Pastikan data yang disimpan memiliki field yang sesuai:
    // - userId (harus sama dengan user.uid)
    // - timestamp (untuk sorting)
    // - nama atau __name__ (untuk nama sekolah)
    // - statusDistribusi (untuk status)
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text('Deliveries'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body:
          user == null
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Silakan login untuk melihat data pengiriman",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection(
                                'recipients',
                              ) // Pastikan collection ini benar
                              .where('userId', isEqualTo: user.uid)
                              .orderBy(
                                'timestamp',
                                descending: true,
                              ) // Pastikan field timestamp ada
                              .limit(50) // Batasi untuk performa
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF9800),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Terjadi kesalahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_shipping,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada pengiriman',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap tombol "Add Delivery" untuk menambahkan pengiriman pertama',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          );
                        }

                        final deliveries = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: deliveries.length,
                          itemBuilder: (context, index) {
                            final docData = deliveries[index].data();
                            final data =
                                docData is Map<String, dynamic>
                                    ? docData
                                    : <String, dynamic>{};

                            // Adjusted field names to match your data structure
                            final String schoolName =
                                data['nama'] ??
                                data['__name__'] ??
                                data['schoolName'] ??
                                'No School Name';
                            final String deliveryTime =
                                data['deliveryTime'] ??
                                data['waktu'] ??
                                'No Time';
                            final int meals =
                                (data['numberOfMeals'] as num? ??
                                        data['jumlahMakanan'] as num? ??
                                        0)
                                    .toInt();
                            final String statusString =
                                data['statusDistribusi'] ??
                                data['status'] ??
                                'Completed';

                            // Debug print untuk melihat data yang diterima
                            print('Debug - Document data: $data');
                            print('Debug - School name: $schoolName');
                            print('Debug - Status: $statusString');

                            final DeliveryStatus status =
                                statusString == 'Pending'
                                    ? DeliveryStatus.inProgress
                                    : DeliveryStatus.completed;

                            return DeliveryCard(
                              time: deliveryTime,
                              location: schoolName,
                              meals: meals,
                              status: status,
                              documentId: deliveries[index].id,
                              onStatusChanged: () {
                                // Refresh akan otomatis terjadi karena StreamBuilder
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      bottomNavigationBar:
          user != null
              ? Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFFF6ED),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () => _navigateToAddDelivery(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add Delivery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}

class DeliveryCard extends StatelessWidget {
  final String time;
  final String location;
  final int meals;
  final DeliveryStatus status;
  final String documentId;
  final VoidCallback? onStatusChanged;

  const DeliveryCard({
    super.key,
    required this.time,
    required this.location,
    required this.meals,
    required this.status,
    required this.documentId,
    this.onStatusChanged,
  });

  Future<void> _updateStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('recipients') // Changed from 'deliveries' to 'recipients'
          .doc(documentId)
          .update({
            'statusDistribusi': // Changed from 'status' to 'statusDistribusi'
                status == DeliveryStatus.inProgress ? 'Completed' : 'Pending',
            'timestamp':
                FieldValue.serverTimestamp(), // Changed from 'updatedAt' to 'timestamp'
          });

      if (onStatusChanged != null) {
        onStatusChanged!();
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color:
                    status == DeliveryStatus.inProgress
                        ? Colors.orange
                        : Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.school, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$meals meals',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge and action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        status == DeliveryStatus.inProgress
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == DeliveryStatus.inProgress
                        ? 'In Progress'
                        : 'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          status == DeliveryStatus.inProgress
                              ? Colors.orange[700]
                              : Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _updateStatus,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      status == DeliveryStatus.inProgress
                          ? Icons.check_circle_outline
                          : Icons.refresh,
                      size: 20,
                      color: Colors.grey[600],
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
