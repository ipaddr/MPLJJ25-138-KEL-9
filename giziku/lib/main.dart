import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // inisialisasi Firebase
  runApp(const GiziKuApp());
}

class GiziKuApp extends StatelessWidget {
  const GiziKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GiziKu',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}
