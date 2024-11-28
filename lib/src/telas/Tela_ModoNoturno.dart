import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaModoNoturno extends StatefulWidget {
  const TelaModoNoturno({super.key});

  @override
  _TelaModoNoturnoState createState() => _TelaModoNoturnoState();
}

class _TelaModoNoturnoState extends State<TelaModoNoturno> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Carregar a preferência de tema
  _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Salvar a preferência de tema
  _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Tela', style: TextStyle(color: Color(0xFFD9D9D9))),
        backgroundColor: const Color(0xFF004AAD),
        iconTheme: const IconThemeData(color: Color(0xFFD9D9D9))
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modo Noturno',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Ativar Modo Noturno'),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                  _saveThemePreference(value); // Salva a escolha do usuário
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
