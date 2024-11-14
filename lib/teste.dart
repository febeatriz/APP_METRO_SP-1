import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class TelaRegistrarExtintor extends StatefulWidget {
  const TelaRegistrarExtintor({super.key});

  @override
  _TelaRegistrarExtintorState createState() => _TelaRegistrarExtintorState();
}

class _TelaRegistrarExtintorState extends State<TelaRegistrarExtintor> {
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _capacidadeController = TextEditingController();
  final TextEditingController _codigoFabricanteController =
      TextEditingController();
  final TextEditingController _dataFabricacaoController =
      TextEditingController();
  final TextEditingController _dataValidadeController = TextEditingController();
  final TextEditingController _ultimaRecargaController =
      TextEditingController();
  final TextEditingController _proximaInspecaoController =
      TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _qrCodeData;

  // Método para combinar os dados e gerar o QR code
  void _generateQrCode() {
    // Combina os dados em um objeto JSON
    Map<String, dynamic> qrCodeData = {
      "patrimonio": _patrimonioController.text,
      "capacidade": _capacidadeController.text,
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "status": _statusController.text,
      "observacoes": _observacoesController.text,
    };

    // Converte o objeto JSON em uma string
    _qrCodeData = jsonEncode(qrCodeData);

    setState(() {});
  }

  // Método para enviar os dados ao servidor
  Future<void> _registerExtintor() async {
    if (_qrCodeData == null) {
      return;
    }

    try {
      // Envia a string JSON ao servidor
      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_extintor'),
        headers: {"Content-Type": "application/json"},
        body: _qrCodeData,
      );

      if (response.statusCode == 200) {
        // Sucesso ao registrar o extintor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extintor registrado com sucesso!')),
        );
      } else {
        // Erro ao registrar o extintor
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar o extintor.')),
        );
      }
    } catch (e) {
      // Trata erros de rede
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão com o servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Extintor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _patrimonioController,
                  decoration: InputDecoration(labelText: 'Patrimônio'),
                ),
                TextFormField(
                  controller: _capacidadeController,
                  decoration: InputDecoration(labelText: 'Capacidade'),
                ),
                TextFormField(
                  controller: _codigoFabricanteController,
                  decoration: InputDecoration(labelText: 'Código Fabricante'),
                ),
                TextFormField(
                  controller: _dataFabricacaoController,
                  decoration: InputDecoration(labelText: 'Data Fabricação'),
                ),
                TextFormField(
                  controller: _dataValidadeController,
                  decoration: InputDecoration(labelText: 'Data Validade'),
                ),
                TextFormField(
                  controller: _ultimaRecargaController,
                  decoration: InputDecoration(labelText: 'Última Recarga'),
                ),
                TextFormField(
                  controller: _proximaInspecaoController,
                  decoration: InputDecoration(labelText: 'Próxima Inspeção'),
                ),
                TextFormField(
                  controller: _statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextFormField(
                  controller: _observacoesController,
                  decoration: InputDecoration(labelText: 'Observações'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _generateQrCode();
                    _registerExtintor();
                  },
                  child: Text('Registrar Extintor'),
                ),
                if (_qrCodeData != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: QrImageView(
                      data: _qrCodeData!,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
