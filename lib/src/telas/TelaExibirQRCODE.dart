import 'package:flutter/material.dart';

class TelaExibirQRCode extends StatelessWidget {
  final String qrCodeData;

  TelaExibirQRCode({required this.qrCodeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code do Extintor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('QR Code gerado:'),
            SizedBox(height: 20),
            Image(
              image: NetworkImage(qrCodeData),
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Erro ao carregar o QR Code',
                      style: TextStyle(color: Colors.red),
                    ),
                    Text(
                      'Verifique a conexão ou a URL do QR Code',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
