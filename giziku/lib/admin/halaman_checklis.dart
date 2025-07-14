import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryChecklistScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryChecklistScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryChecklistScreen> createState() =>
      _DeliveryChecklistScreenState();
}

class _DeliveryChecklistScreenState extends State<DeliveryChecklistScreen> {
  bool _isAdding = false;
  String? _schoolName;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryInfo();
  }

  Future<void> _fetchDeliveryInfo() async {
    try {
      final deliveryDoc =
          await FirebaseFirestore.instance
              .collection('deliveries')
              .doc(widget.deliveryId)
              .get();
      if (deliveryDoc.exists) {
        if (mounted)
          setState(() => _schoolName = deliveryDoc.data()?['schoolName']);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _populateStudentList() async {
    if (_schoolName == null) return;
    setState(() => _isAdding = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();
      final masterStudents =
          await firestore
              .collection('students')
              .where('schoolName', isEqualTo: _schoolName)
              .get();
      final deliveryRecipientsRef = firestore
          .collection('deliveries')
          .doc(widget.deliveryId)
          .collection('recipients');

      for (var studentDoc in masterStudents.docs) {
        final studentData = studentDoc.data();
        final studentId = studentDoc.id;
        batch.set(deliveryRecipientsRef.doc(studentId), {
          'studentName': studentData['name'],
          'class': studentData['class'],
          'status': 'Absent',
          'studentId': studentId,
        });
      }
      await batch.commit();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipientsRef = FirebaseFirestore.instance
        .collection('deliveries')
        .doc(widget.deliveryId)
        .collection('recipients');

    return Scaffold(
      appBar: AppBar(title: Text(_schoolName ?? 'Daftar Kehadiran')),
      body: StreamBuilder<QuerySnapshot>(
        stream: recipientsRef.orderBy('studentName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: _isAdding ? null : _populateStudentList,
                child:
                    _isAdding
                        ? const CircularProgressIndicator()
                        : const Text('Isi Daftar Siswa'),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final bool hasReceived = data['status'] == 'Received';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(data['studentName'] ?? 'No Name'),
                  subtitle: Text("Kelas ${data['class'] ?? ''}"),
                  trailing: Checkbox(
                    value: hasReceived,
                    onChanged:
                        (value) => recipientsRef.doc(doc.id).update({
                          'status': value! ? 'Received' : 'Absent',
                        }),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
