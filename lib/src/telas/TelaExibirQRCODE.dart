import 'package:flutter/material.dart';

class TelaExibirQRCODE extends StatelessWidget {
  // final String qrCodeUrl;

  // TelaExibirQRCODE({required this.qrCodeUrl}) {
    // Coloque o print aqui, para verificar a URL do QR Code
    // print(qrCodeUrl);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code do Extintor'),
        backgroundColor: const Color(0xFF011689),
      ),
      body: Center(
        child: Image.network(
        "http://192.168.0.6:3001/uploads/qrcodes/4.png",
        width: 200,
        height: 200,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          );
        },
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.error,
          color: Colors.red,
          size: 100,
        ),
      )

      ),
    );
  }
}
