import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ScannerScreen()),
            );
          },
        ),

        title: const Text('QR Scanner', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Kamera scanner
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('QR Code Detected: ${barcode.rawValue}');
                // TODO: Lakukan sesuatu dengan nilai QR
              }
            },
          ),

          // Frame kotak scanner
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Tombol input manual
          Positioned(
            bottom: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController controller =
                        TextEditingController();
                    return AlertDialog(
                      title: const Text('Masukkan Kode'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 123456',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batalkan'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final code = controller.text;
                            debugPrint('Kode dimasukkan secara manual: $code');
                            Navigator.pop(context);

                            // TODO: Gunakan kode tersebut (validasi/navigasi)
                          },
                          child: const Text('Kirim'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.keyboard),
              label: const Text('Masukkan Kode Secara Manual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
