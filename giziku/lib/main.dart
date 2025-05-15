import 'package:flutter/material.dart';
import 'login/login.dart';

void main() {
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
