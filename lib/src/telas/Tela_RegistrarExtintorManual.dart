import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  final TextEditingController _observacoesController = TextEditingController();

  String? _tipoSelecionado;
  String? _linhaSelecionada;
  String? _statusSelecionado;
  String? _localizacaoSelecionada;
  String? _qrCodeData;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> status = [];
  List<Map<String, dynamic>> localizacoes = [];

  @override
  void initState() {
    super.initState();
    fetchTipos();
    fetchLinhas();
    fetchStatus();
    fetchLocalizacoes();
  }

  Future<void> fetchTipos() async {
    final response =
        await http.get(Uri.parse('http://localhost:3001/tipos-extintores'));
    if (response.statusCode == 200) {
      setState(() {
        tipos =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLinhas() async {
    final response = await http.get(Uri.parse('http://localhost:3001/linhas'));
    if (response.statusCode == 200) {
      setState(() {
        linhas =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchStatus() async {
    final response = await http.get(Uri.parse('http://localhost:3001/status'));
    if (response.statusCode == 200) {
      setState(() {
        status =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  Future<void> fetchLocalizacoes() async {
    final response =
        await http.get(Uri.parse('http://localhost:3001/localizacoes'));
    if (response.statusCode == 200) {
      setState(() {
        localizacoes =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    }
  }

  void _generateQrCode() {
    Map<String, dynamic> qrCodeData = {
      "patrimonio": _patrimonioController.text,
      "tipo_id": _tipoSelecionado,
      "capacidade": _capacidadeController.text,
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "status": _statusSelecionado,
      "linha_id": _linhaSelecionada,
      "id_localizacao": _localizacaoSelecionada,
      "observacoes": _observacoesController.text,
    };

    _qrCodeData = jsonEncode(qrCodeData);
    setState(() {});
  }

  Future<void> _registerExtintor() async {
    if (_qrCodeData == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_extintor'),
        headers: {"Content-Type": "application/json"},
        body: _qrCodeData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extintor registrado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar o extintor.')),
        );
      }
    } catch (e) {
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _patrimonioController,
                  decoration: InputDecoration(labelText: 'Patrimônio'),
                ),
                DropdownButtonFormField(
                  value: _tipoSelecionado,
                  decoration: InputDecoration(labelText: 'Tipo'),
                  items: tipos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo['id'].toString(),
                      child: Text(tipo['nome']),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _tipoSelecionado = valor;
                    });
                  },
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
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _dataFabricacaoController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                TextFormField(
                  controller: _dataValidadeController,
                  decoration: InputDecoration(labelText: 'Data Validade'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _dataValidadeController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                TextFormField(
                  controller: _ultimaRecargaController,
                  decoration: InputDecoration(labelText: 'Última Recarga'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _ultimaRecargaController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                TextFormField(
                  controller: _proximaInspecaoController,
                  decoration: InputDecoration(labelText: 'Próxima Inspeção'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _proximaInspecaoController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
                DropdownButtonFormField(
                  value: _statusSelecionado,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: status.map((status) {
                    return DropdownMenuItem(
                      value: status['id'].toString(),
                      child: Text(status['nome']),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _statusSelecionado = valor;
                    });
                  },
                ),
                DropdownButtonFormField(
                  value: _linhaSelecionada,
                  decoration: InputDecoration(labelText: 'Linha'),
                  items: linhas.map((linha) {
                    return DropdownMenuItem(
                      value: linha['id'].toString(),
                      child: Text(linha['nome']),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _linhaSelecionada = valor;
                    });
                  },
                ),
                DropdownButtonFormField(
                  value: _localizacaoSelecionada,
                  decoration: InputDecoration(labelText: 'Localização'),
                  items: localizacoes.map((localizacao) {
                    return DropdownMenuItem(
                      value: localizacao['id'].toString(),
                      child: Text(localizacao['nome']),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _localizacaoSelecionada = valor;
                    });
                  },
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
