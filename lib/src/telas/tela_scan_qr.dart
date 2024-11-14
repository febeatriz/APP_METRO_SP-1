import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

class TelaScanQR extends StatefulWidget {
  @override
  _TelaScanQRState createState() => _TelaScanQRState();
}

class _TelaScanQRState extends State<TelaScanQR> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor = const Color(0xFF011689);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR Code',
            style: TextStyle(color: Colors.white)),
        backgroundColor: baseColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _scanFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (!mounted) return;
      controller.pauseCamera();
      if (scanData.code != null) {
        Navigator.pushNamed(
          context,
          '/info-extintor',
          arguments: scanData.code,
        ).then((_) => controller.resumeCamera());
      } else {
        controller.resumeCamera();
      }
    });
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      try {
        final qrCode = await QrCodeToolsPlugin.decodeFrom(pickedImage.path);
        if (qrCode != null) {
          Navigator.pushNamed(context, '/info-extintor', arguments: qrCode);
        } else {
          _showError("QR code não encontrado na imagem.");
        }
      } catch (e) {
        _showError("Erro ao ler QR code: $e");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
