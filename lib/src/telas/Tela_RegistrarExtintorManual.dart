import 'package:flutter/material.dart';

class TelaRegistrarExtintor extends StatelessWidget {
  final Color azulPersonalizado =
      Color(0xFF003399); // Ajuste aqui conforme desejado

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Cor de fundo da tela
      child: Column(
        children: [
          // Parte superior com a cor azul que pode ser ajustada
          Container(
            height: 200, // Altura ajustável da seção azul
            color: azulPersonalizado,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fire_extinguisher,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Preencha os campos abaixo\npara registrar um extintor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  buildTextField('Número do Extintor'),
                  buildTextField('Composição'),
                  buildTextField('Linha'),
                  buildTextField('Localização'),
                  buildTextField('Observação'),
                  buildTextField('Data do Registro'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Cor do botão
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'REGISTRAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar campos de texto
  Widget buildTextField(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
