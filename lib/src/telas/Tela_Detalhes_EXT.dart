import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// Nova tela para exibir detalhes do extintor
class TelaDetalhesExtintor extends StatelessWidget {
  final String extintorId;

  TelaDetalhesExtintor({required this.extintorId});
  
  get http => null;

  Future<Map<String, dynamic>> _buscarDadosExtintor() async {
    final response = await http.get(
      Uri.parse('http://localhost:3001/extintores/$extintorId'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Extintor')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _buscarDadosExtintor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Erro ao buscar dados');
          }
          final data = snapshot.data;
          return data != null
              ? ListView(
                  children: [
                    Text('Patrimônio: ${data['patrimonio']}'),
                    Text('Capacidade: ${data['capacidade']}'),
                    Text('Status: ${data['status']}'),
                    // Adicione todos os outros campos aqui
                  ],
                )
              : Text('Extintor não encontrado');
        },
      ),
    );
  }
}
