import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
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
  String? _localizacaoSelecionada;
  String? _statusSelecionado;
  String? _qrCodeData;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> localizacoesFiltradas = [];
  List<Map<String, dynamic>> status = [];

  @override
  void initState() {
    super.initState();
    fetchTipos();
    fetchLinhas();
    fetchStatus();
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

  Future<void> fetchLocalizacoes(String linhaId) async {
    final response = await http
        .get(Uri.parse('http://localhost:3001/localizacoes?linhaId=$linhaId'));

    if (response.statusCode == 200) {
      setState(() {
        localizacoesFiltradas =
            List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
      });
    } else {
      print('Erro ao buscar localizações: ${response.statusCode}');
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

  void _generateQrCode() {
    if (_patrimonioController.text.isEmpty ||
        _tipoSelecionado == null ||
        _capacidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return;
    }

    setState(() {
      _qrCodeData = jsonEncode({
        "patrimonio": _patrimonioController.text,
        "tipo_id": _tipoSelecionado,
        "capacidade": _capacidadeController.text,
        "codigo_fabricante": _codigoFabricanteController.text,
        "data_fabricacao": _dataFabricacaoController.text,
        "data_validade": _dataValidadeController.text,
        "ultima_recarga": _ultimaRecargaController.text,
        "proxima_inspecao": _proximaInspecaoController.text,
        "linha_id": _linhaSelecionada,
        "localizacao_id": _localizacaoSelecionada,
        "status": _statusSelecionado,
        "observacoes": _observacoesController.text,
      });
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _registrarExtintor() async {
    if (_patrimonioController.text.isEmpty ||
        _tipoSelecionado == null ||
        _capacidadeController.text.isEmpty ||
        _linhaSelecionada == null ||
        _localizacaoSelecionada == null ||
        _statusSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return;
    }

    final extintorData = {
      "patrimonio": _patrimonioController.text,
      "tipo_id": _tipoSelecionado,
      "capacidade": _capacidadeController.text,
      "codigo_fabricante": _codigoFabricanteController.text,
      "data_fabricacao": _dataFabricacaoController.text,
      "data_validade": _dataValidadeController.text,
      "ultima_recarga": _ultimaRecargaController.text,
      "proxima_inspecao": _proximaInspecaoController.text,
      "linha_id": _linhaSelecionada,
      "localizacao_id": _localizacaoSelecionada,
      "status": _statusSelecionado,
      "observacoes": _observacoesController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_extintor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(extintorData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extintor registrado com sucesso!')),
        );
        setState(() {
          _patrimonioController.clear();
          _capacidadeController.clear();
          _codigoFabricanteController.clear();
          _dataFabricacaoController.clear();
          _dataValidadeController.clear();
          _ultimaRecargaController.clear();
          _proximaInspecaoController.clear();
          _observacoesController.clear();
          _tipoSelecionado = null;
          _linhaSelecionada = null;
          _localizacaoSelecionada = null;
          _statusSelecionado = null;
          _qrCodeData = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao registrar extintor: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Extintor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                DropdownButtonFormField(
                  value: _linhaSelecionada,
                  decoration: InputDecoration(labelText: 'Linha'),
                  items: linhas.map((linha) {
                    return DropdownMenuItem(
                      value: linha['id'].toString(),
                      child: Text(linha['nome']),
                    );
                  }).toList(),
                  onChanged: (linhaId) {
                    setState(() {
                      _linhaSelecionada = linhaId;
                      _localizacaoSelecionada = null;
                      localizacoesFiltradas.clear();
                    });
                    fetchLocalizacoes(linhaId!);
                  },
                ),
                DropdownButtonFormField(
                  value: _localizacaoSelecionada,
                  decoration: InputDecoration(labelText: 'Localização'),
                  items: localizacoesFiltradas.map((localizacao) {
                    return DropdownMenuItem(
                      value: localizacao['id'].toString(),
                      child: Text(
                          '${localizacao['subarea']} - ${localizacao['local_detalhado']}'),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _localizacaoSelecionada = valor;
                    });
                  },
                ),
                TextFormField(
                  controller: _codigoFabricanteController,
                  decoration: InputDecoration(labelText: 'Código Fabricante'),
                ),
                DropdownButtonFormField(
                  value: _statusSelecionado,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: status.map((statusItem) {
                    return DropdownMenuItem(
                      value: statusItem['id'].toString(),
                      child: Text(statusItem[
                          'nome']), // Substitua 'nome' pelo campo correto da API, se diferente
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _statusSelecionado = valor;
                    });
                  },
                ),
                TextFormField(
                  controller: _dataFabricacaoController,
                  decoration: InputDecoration(labelText: 'Data de Fabricação'),
                  readOnly: true,
                  onTap: () => _selectDate(_dataFabricacaoController),
                ),
                TextFormField(
                  controller: _dataValidadeController,
                  decoration: InputDecoration(labelText: 'Data de Validade'),
                  readOnly: true,
                  onTap: () => _selectDate(_dataValidadeController),
                ),
                TextFormField(
                  controller: _ultimaRecargaController,
                  decoration: InputDecoration(labelText: 'Última Recarga'),
                  readOnly: true,
                  onTap: () => _selectDate(_ultimaRecargaController),
                ),
                TextFormField(
                  controller: _proximaInspecaoController,
                  decoration: InputDecoration(labelText: 'Próxima Inspeção'),
                  readOnly: true,
                  onTap: () => _selectDate(_proximaInspecaoController),
                ),
                TextFormField(
                  controller: _observacoesController,
                  decoration: InputDecoration(labelText: 'Observações'),
                ),
                ElevatedButton(
                  onPressed: _generateQrCode,
                  child: Text('Gerar QR Code'),
                ),
                if (_qrCodeData != null)
                  Center(
                    child: QrImageView(data: _qrCodeData!, size: 200),
                  ),
                ElevatedButton(
                  onPressed: _registrarExtintor,
                  child: Text('Registrar Extintor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
