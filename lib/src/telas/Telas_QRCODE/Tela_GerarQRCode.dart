import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importa a biblioteca para gerar QR Code

class TelaGerarQRCode extends StatelessWidget {
  final String numero;
  final String composicao;
  final String linha;
  final String localizacao;
  final String observacao;
  final String dataRegistro;

  const TelaGerarQRCode({
    required this.numero,
    required this.composicao,
    required this.linha,
    required this.localizacao,
    required this.observacao,
    required this.dataRegistro,
  });

  @override
  Widget build(BuildContext context) {
    String qrData =
        'Número: $numero\nComposição: $composicao\nLinha: $linha\nLocalização: $localizacao\nObservação: $observacao\nData de Registro: $dataRegistro';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar QR Code'),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              size: 250,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aqui você pode implementar a lógica para imprimir o QR Code
                print('QR Code gerado com sucesso!');
              },
              child: const Text(
                'Imprimir QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
