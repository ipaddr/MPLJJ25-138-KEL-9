import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart'; // Pastikan nama file sesuai
import '../login/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Referensi ke dokumen profil di Firestore
    final DocumentReference profileRef = FirebaseFirestore.instance
        .collection('vendors')
        .doc('main_profile');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED), // Warna latar belakang
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFF9800),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: profileRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Profile data not found.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        ),
                    child: const Text('Create Profile'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final vendorName = data['vendorName'] ?? 'No Name';
          final description = data['description'] ?? 'No Description';
          final openHours = data['openHours'] ?? '-';
          final location = data['location'] ?? '-';
          final contactNumber = data['contactNumber'] ?? '-';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.storefront, size: 80),
                  const SizedBox(height: 8),
                  Text(
                    vendorName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  _infoCard(
                    icon: Icons.access_time,
                    label: 'Open Hours',
                    value: openHours,
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: location.replaceAll(
                      ', ',
                      ',\n',
                    ), // Agar bisa multiline
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.phone,
                    label: 'Phone Number',
                    value: contactNumber,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: _buildSettingsCard(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement Firebase Auth Logout
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.black),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: const Row(
        children: [
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 12),
          Expanded(child: Text('Edit Profile')),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
