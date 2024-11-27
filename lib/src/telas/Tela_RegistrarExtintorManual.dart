import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class TelaRegistrarExtintor extends StatefulWidget {
  const TelaRegistrarExtintor({super.key});

  @override
  _TelaRegistrarExtintorState createState() => _TelaRegistrarExtintorState();
}

class _TelaRegistrarExtintorState extends State<TelaRegistrarExtintor> {
  // Controladores
  final _patrimonioController = TextEditingController();
  final _capacidadeController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _dataFabricacaoController = TextEditingController();
  final _dataValidadeController = TextEditingController();
  final _ultimaRecargaController = TextEditingController();
  final _proximaInspecaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _tipoSelecionado;
  String? _linhaSelecionada;
  String? _localizacaoSelecionada;
  String? _statusSelecionado;
  String? _qrCodeUrl;

  List<Map<String, dynamic>> tipos = [];
  List<Map<String, dynamic>> linhas = [];
  List<Map<String, dynamic>> localizacoesFiltradas = [];
  List<Map<String, dynamic>> status = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([fetchTipos(), fetchLinhas(), fetchStatus()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchTipos() async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedTipos = prefs.getString('tipos');
    if (cachedTipos != null) {
      setState(() {
        tipos =
            List<Map<String, dynamic>>.from(json.decode(cachedTipos)['data']);
      });
    } else {
      final response =
          await http.get(Uri.parse('http://localhost:3001/tipos-extintores'));
      if (response.statusCode == 200) {
        prefs.setString('tipos', response.body);
        setState(() {
          tipos = List<Map<String, dynamic>>.from(
              json.decode(response.body)['data']);
        });
      }
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

  Future<void> _registrarExtintor() async {
    if (_patrimonioController.text.isEmpty ||
        _tipoSelecionado == null ||
        _capacidadeController.text.isEmpty ||
        _linhaSelecionada == null ||
        _localizacaoSelecionada == null ||
        _statusSelecionado == null) {
      _showErrorDialog('Preencha todos os campos obrigatórios.');
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
      "id_localizacao": _localizacaoSelecionada,
      "status": _statusSelecionado,
      "observacoes": _observacoesController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_extintor'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(extintorData),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          _qrCodeUrl = responseData['qrCodeUrl'];
        });
        _showSuccessDialog('Extintor registrado com sucesso!');
      } else {
        _showErrorDialog('Erro ao registrar extintor: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Erro de conexão: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidDate(String date) {
    try {
      DateFormat('dd/MM/yyyy').parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isDate = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isDate,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Preto
        filled: true,
        fillColor: const Color(0xFFF4F4F9), // Fundo claro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onTap: isDate ? () => _selectDate(controller) : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    String? value,
    required Function(String?) onChanged,
    String Function(Map<String, dynamic>)? displayItem,
  }) {
    return DropdownButtonFormField(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item['id'].toString(),
                child: Text(
                    displayItem != null ? displayItem(item) : item['nome']),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black), // Preto
        filled: true,
        fillColor: const Color(0xFFF4F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF011689),
        title: const Text('Registrar Extintor'), 
        foregroundColor: Colors.white, // Cor do texto do título
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildTextField(
                      controller: _patrimonioController,
                      label: 'Patrimônio',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Tipo',
                      items: tipos,
                      value: _tipoSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _tipoSelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _capacidadeController,
                      label: 'Capacidade (L)',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _codigoFabricanteController,
                      label: 'Código do Fabricante',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _dataFabricacaoController,
                      label: 'Data de Fabricação',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _dataValidadeController,
                      label: 'Data de Validade',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _ultimaRecargaController,
                      label: 'Última Recarga',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _proximaInspecaoController,
                      label: 'Próxima Inspeção',
                      isDate: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Linha',
                      items: linhas,
                      value: _linhaSelecionada,
                      onChanged: (value) {
                        setState(() {
                          _linhaSelecionada = value;
                          fetchLocalizacoes(value!);
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Localização',
                      items: localizacoesFiltradas,
                      value: _localizacaoSelecionada,
                      onChanged: (value) =>
                          setState(() => _localizacaoSelecionada = value),
                      displayItem: (item) =>
                          '${item['subarea']} - ${item['local_detalhado']}',
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Status',
                      items: status,
                      value: _statusSelecionado,
                      onChanged: (value) {
                        setState(() {
                          _statusSelecionado = value;
                        });
                      },
                      displayItem: (item) => item['nome'],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _observacoesController,
                      label: 'Observações',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registrarExtintor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF011689), // Azul
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_qrCodeUrl != null) ...[
                      Text('QR Code gerado com sucesso!'),
                      Image.network(_qrCodeUrl!),
                      ElevatedButton(
                        onPressed: () {
                          Share.share(
                              'Confira o QR Code do extintor: $_qrCodeUrl');
                        },
                        child: const Text('Compartilhar QR Code'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
