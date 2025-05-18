import 'package:flutter/material.dart';
import 'vendor/form_delivery.dart';

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
      home: const FormDeliveryPage(),
    );
  }
}
