import 'package:flutter/material.dart';
import 'user/edit_profile.dart'; // ⬅️ Ini WAJIB, karena NotificationScreen didefinisikan di sini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EditProfileScreen(), // ⬅️ pastikan ini cocok dengan class
    );
  }
}
