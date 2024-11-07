import 'package:flutter/material.dart';

class TelaExibirInformacoes extends StatelessWidget {
  final String numero;
  final String composicao;
  final String linha;
  final String localizacao;
  final String observacao;
  final String dataRegistro;

  TelaExibirInformacoes({
    required this.numero,
    required this.composicao,
    required this.linha,
    required this.localizacao,
    required this.observacao,
    required this.dataRegistro,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Extintor'),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.confirmation_number, 'Número', numero),
            _buildInfoRow(Icons.science, 'Composição', composicao),
            _buildInfoRow(Icons.train, 'Linha', linha),
            _buildInfoRow(Icons.location_on, 'Localização', localizacao),
            _buildInfoRow(Icons.note_alt, 'Observação', observacao),
            _buildInfoRow(Icons.calendar_today, 'Data do Registro', dataRegistro),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF004AAD)),
          const SizedBox(width: 10),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
