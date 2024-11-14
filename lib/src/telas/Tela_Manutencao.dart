import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ManutencaoExtintorPage extends StatefulWidget {
  @override
  _ManutencaoExtintorPageState createState() => _ManutencaoExtintorPageState();
}

class _ManutencaoExtintorPageState extends State<ManutencaoExtintorPage> {
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController responsavelController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();
  DateTime? dataManutencao;
  DateTime? ultimaRecarga;
  DateTime? proximaInspecao;
  DateTime? vencimento;
  int? idExtintor;
  bool revisarStatus = false; // Controle de revisão de status

  List<Map<String, dynamic>> extintores = [];

  @override
  void initState() {
    super.initState();
    _carregarExtintores();
  }

  // Função para carregar os extintores do backend
  Future<void> _carregarExtintores() async {
    final url = Uri.parse('http://localhost:3001/extintores');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          extintores = List<Map<String, dynamic>>.from(data['extintores']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao carregar extintores'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro de comunicação com o servidor'),
      ));
    }
  }

  // Função para salvar a manutenção e atualizar o status do extintor
  Future<void> _salvarManutencao() async {
    if (idExtintor == null ||
        descricaoController.text.isEmpty ||
        responsavelController.text.isEmpty ||
        dataManutencao == null ||
        ultimaRecarga == null ||
        proximaInspecao == null ||
        vencimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Todos os campos devem ser preenchidos"),
      ));
      return;
    }

    final url = Uri.parse('http://localhost:3001/salvar_manutencao');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patrimonio': idExtintor,
          'descricao': descricaoController.text,
          'responsavel': responsavelController.text,
          'observacoes': observacoesController.text,
          'data_manutencao': DateFormat('yyyy-MM-dd').format(dataManutencao!),
          'ultima_recarga': DateFormat('yyyy-MM-dd').format(ultimaRecarga!),
          'proxima_inspecao': DateFormat('yyyy-MM-dd').format(proximaInspecao!),
          'data_vencimento': DateFormat('yyyy-MM-dd').format(vencimento!),
          'revisar_status': revisarStatus,
        }));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Manutenção salva com sucesso!"),
        ));
        // Verifica se a revisão do status foi solicitada
        if (revisarStatus) {
          _mostrarRevisaoStatus();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro ao salvar a manutenção"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Erro ao comunicar com o servidor: ${response.statusCode}"),
      ));
    }
  }

  // Função para exibir a revisão manual do status
  void _mostrarRevisaoStatus() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Revisar Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja alterar o status do extintor para "Ativo"?'),
              SwitchListTile(
                title: Text("Alterar para Ativo"),
                value: revisarStatus,
                onChanged: (bool value) {
                  setState(() {
                    revisarStatus = value;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirmar"),
              onPressed: () {
                // Atualize o status do extintor no backend com base na revisão
                _atualizarStatus();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Função para atualizar o status no servidor
  Future<void> _atualizarStatus() async {
    final url = Uri.parse('http://localhost:3001/atualizar_status');
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patrimonio': idExtintor,
          'status': revisarStatus ? 'Ativo' : 'Em Manutenção',
        }));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Status atualizado com sucesso!"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro ao atualizar o status"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Erro ao comunicar com o servidor: ${response.statusCode}"),
      ));
    }
  }

  // Função para selecionar a data
  Future<void> _selecionarData(BuildContext context, String tipoData) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        switch (tipoData) {
          case 'manutencao':
            dataManutencao = picked;
            break;
          case 'recarga':
            ultimaRecarga = picked;
            break;
          case 'inspecao':
            proximaInspecao = picked;
            break;
          case 'vencimento':
            vencimento = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Histórico de Manutenção")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<int>(
              value: idExtintor,
              hint: Text("Selecione o Extintor"),
              onChanged: (int? newValue) {
                setState(() {
                  idExtintor = newValue;
                });
              },
              items: extintores.map((extintor) {
                return DropdownMenuItem<int>(
                  value: extintor['Patrimonio'],
                  child: Text('Extintor ${extintor['Patrimonio']}'),
                );
              }).toList(),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição da Manutenção'),
            ),
            TextField(
              controller: responsavelController,
              decoration:
                  InputDecoration(labelText: 'Responsável pela Manutenção'),
            ),
            TextField(
              controller: observacoesController,
              decoration: InputDecoration(labelText: 'Observações'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selecionarData(context, 'manutencao'),
                    child: Text(dataManutencao == null
                        ? 'Data da Manutenção'
                        : DateFormat('dd/MM/yyyy').format(dataManutencao!)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selecionarData(context, 'recarga'),
                    child: Text(ultimaRecarga == null
                        ? 'Última Recarga'
                        : DateFormat('dd/MM/yyyy').format(ultimaRecarga!)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selecionarData(context, 'inspecao'),
                    child: Text(proximaInspecao == null
                        ? 'Próxima Inspeção'
                        : DateFormat('dd/MM/yyyy').format(proximaInspecao!)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selecionarData(context, 'vencimento'),
                    child: Text(vencimento == null
                        ? 'Data de Vencimento'
                        : DateFormat('dd/MM/yyyy').format(vencimento!)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text("Revisar Status do Extintor?"),
              value: revisarStatus,
              onChanged: (bool value) {
                setState(() {
                  revisarStatus = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvarManutencao,
              child: Text("Salvar Manutenção"),
            ),
          ],
        ),
      ),
    );
  }
}
