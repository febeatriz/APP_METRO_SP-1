import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  @override
  QrCodeScannerState createState() => QrCodeScannerState();
}

class QrCodeScannerState extends State<QrCodeScanner> {
  final GlobalKey<QrCodeScannerState> qrKey = GlobalKey<QrCodeScannerState>();
  QRViewController? controller;
  String scannedData = '';

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code Scanner")),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  setState(() {
                    scannedData = scanData.code ?? 'Sem dados';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoExtintorScreen(info: scannedData),
                      ),
                    );
                  });
                });
              },
            ),
          ),
          Text('Dados escaneados: $scannedData'),
        ],
      ),
    );
  }
}

class InfoExtintorScreen extends StatelessWidget {
  final String info;

  InfoExtintorScreen({required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Informações do Extintor")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Informações do Extintor:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text(info, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
