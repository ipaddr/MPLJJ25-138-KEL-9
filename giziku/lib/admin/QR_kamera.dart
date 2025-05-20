import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFEF7EF);
    const orangeColor = Color(0xFFFFA500);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: orangeColor,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text('QR Scanner', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),

          // QR Scanner View
          SizedBox(
            width: 250,
            height: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                controller: MobileScannerController(),
                onDetect: (BarcodeCapture capture) {
                  final barcode = capture.barcodes.first;
                  final String? code = barcode.rawValue;

                  if (code != null) {
                    debugPrint('QR Code detected: $code');
                    Navigator.pop(
                      context,
                      code,
                    ); // kembali ke screen sebelumnya
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Position QR code within frame',
            style: TextStyle(color: Colors.black87),
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Tambahkan navigasi ke input manual jika perlu
              debugPrint("Manual input tapped");
            },
            icon: const Icon(Icons.keyboard),
            label: const Text('Enter Code Manually'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
