import 'package:flutter/material.dart';
import 'admin/dashboard_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GiziKuApp());
}

class GiziKuApp extends StatelessWidget {
  const GiziKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GiziK',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardAdmin(),
    );
  }
}
