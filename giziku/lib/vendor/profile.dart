import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import '../login/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan user yang sedang login
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Jika tidak ada user yang login, redirect ke login
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Referensi ke dokumen profil user yang sedang login
    final DocumentReference profileRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Profile data not found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      // Refresh halaman setelah kembali dari edit
                      if (result != null) {
                        // StreamBuilder akan otomatis refresh
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create Profile'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Mengambil data dari Firestore dengan fallback values
          final businessName =
              data['businessName'] ??
              data['username'] ??
              data['name'] ??
              'Healthy Kitchen';
          final businessDescription =
              data['businessDescription'] ??
              data['description'] ??
              'Trusted Healthy Food Supplier';
          final openHours =
              data['openHours'] ?? data['operatingHours'] ?? '08:00 - 20:00';
          final location =
              data['location'] ?? data['address'] ?? 'Padang, Indonesia';
          final phoneNumber =
              data['phoneNumber'] ??
              data['phone'] ??
              data['contactNumber'] ??
              '+62 8123-124-2346';

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Logo/Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Business Name
                        Text(
                          businessName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Business Description
                        Text(
                          businessDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Open Hours
                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: 'Open Hours',
                          value: openHours,
                        ),

                        const SizedBox(height: 20),

                        // Location
                        _buildInfoRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: location,
                        ),

                        const SizedBox(height: 20),

                        // Phone Number
                        _buildInfoRow(
                          icon: Icons.phone,
                          label: 'Phone Number',
                          value: phoneNumber,
                        ),

                        const SizedBox(height: 20),

                        // Edit Profile
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            // StreamBuilder akan otomatis refresh ketika data berubah
                          },
                          child: _buildInfoRow(
                            icon: Icons.settings,
                            label: 'Edit Profile',
                            value: '',
                            showArrow: true,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Logout Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final bool? shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Logout'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true) {
                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          );

                          await FirebaseAuth.instance.signOut();

                          // Close loading dialog
                          if (context.mounted) {
                            Navigator.of(context).pop();

                            // Navigate to login
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          // Close loading dialog
                          if (context.mounted) {
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error signing out: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.black),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showArrow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (showArrow)
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
          else
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
