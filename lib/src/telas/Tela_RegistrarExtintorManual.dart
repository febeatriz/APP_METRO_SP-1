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
  String? _qrCodeData; // Variável para armazenar os dados do QR Code

  List<Map<String, dynamic>> _tiposExtintores = [];
  List<Map<String, dynamic>> _localizacoes = [];
  List<Map<String, dynamic>> _linhas = [];
  String? _selectedTipo;
  String? _selectedLocalizacao;
  String? _selectedLinha;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTiposExtintores();
    _fetchLocalizacoes();
    _fetchLinhas();
  }

  Future<void> _fetchTiposExtintores() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3001/tipos-extintores'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tiposExtintores = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } catch (error) {
      print("Erro ao buscar tipos de extintores: $error");
    }
  }

  Future<void> _fetchLocalizacoes() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3001/localizacoes'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _localizacoes = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } catch (error) {
      print("Erro ao buscar localizações: $error");
    }
  }

  Future<void> _fetchLinhas() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3001/linhas'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _linhas = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } catch (error) {
      print("Erro ao buscar linhas: $error");
    }
  }

  String formatarData(String data) {
    final partes = data.split('/');
    if (partes.length != 3) {
      throw FormatException('Formato de data inválido');
    }
    return '${partes[2]}-${partes[1]}-${partes[0]}';
  }

  Future<void> _registrarExtintor() async {
    try {
      final patrimonio = _patrimonioController.text;
      final capacidade = _capacidadeController.text;
      final codigoFabricante = _codigoFabricanteController.text;
      final dataFabricacao = formatarData(_dataFabricacaoController.text);
      final dataValidade = formatarData(_dataValidadeController.text);
      final ultimaRecarga = formatarData(_ultimaRecargaController.text);
      final proximaInspecao = formatarData(_proximaInspecaoController.text);
      final status = _statusController.text;
      final idLocalizacao = _selectedLocalizacao;
      final linhaId = _selectedLinha;
      final observacoes = _observacoesController.text;

      final data = {
        'patrimonio': patrimonio,
        'tipo_id': _selectedTipo,
        'capacidade': capacidade,
        'codigo_fabricante': codigoFabricante,
        'data_fabricacao': dataFabricacao,
        'data_validade': dataValidade,
        'ultima_recarga': ultimaRecarga,
        'proxima_inspecao': proximaInspecao,
        'status': status,
        'id_localizacao': idLocalizacao,
        'linha_id': linhaId,
        'observacoes': observacoes,
      };

      final response = await http.post(
        Uri.parse('http://localhost:3001/registrar_extintor'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        setState(() {
          _qrCodeData =
              responseData['qrCode']; // Define o dado a ser exibido no QR Code
        });
      } else {
        _showError(responseData['message']);
      }
    } catch (error) {
      print('Erro ao registrar o extintor: $error');
      _showError('Erro ao registrar o extintor');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF011689),
          elevation: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpeg',
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 8),
              const Text(
                'Registrar Extintor',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: const Color(0xFF011689),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: Center(
                        child: SingleChildScrollView(
                            child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Preencha os campos abaixo para registrar um extintor',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(color: Colors.black12),
                          _buildTextField('Patrimônio', _patrimonioController),
                          _buildDropdownField(
                              'Tipo', _tiposExtintores, _selectedTipo, (value) {
                            setState(() => _selectedTipo = value);
                          }),
                          _buildTextField('Capacidade', _capacidadeController),
                          _buildTextField('Código do Fabricante',
                              _codigoFabricanteController),
                          _buildDateField(
                              'Data de Fabricação', _dataFabricacaoController),
                          _buildDateField(
                              'Data de Validade', _dataValidadeController),
                          _buildDateField(
                              'Última Recarga', _ultimaRecargaController),
                          _buildDateField(
                              'Próxima Inspeção', _proximaInspecaoController),
                          _buildTextField('Status', _statusController),
                          _buildDropdownField('Linha', _linhas, _selectedLinha,
                              (value) {
                            setState(() => _selectedLinha = value);
                          }),
                          _buildDropdownField('Localização', _localizacoes,
                              _selectedLocalizacao, (value) {
                            setState(() => _selectedLocalizacao = value);
                          }),
                          _buildTextField(
                              'Observações', _observacoesController),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _registrarExtintor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF011689),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Registrar Extintor',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                          const SizedBox(height: 20),
                          if (_qrCodeData != null)
                            Column(
                              children: [
                                const Text('QR Code Gerado:'),
                                QrImageView(
                                  data: _qrCodeData!,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                              ],
                            )
                        ]),
                      ),
                    ]))))));
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.none,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<Map<String, dynamic>> items,
      String? selectedItem, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        onChanged: (value) {
          onChanged(value);
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(item['nome']),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Este campo é obrigatório';
          }
          return null;
        },
      ),
    );
  }
}
