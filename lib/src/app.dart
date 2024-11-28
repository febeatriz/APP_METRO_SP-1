import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/TelaScanQR.dart';
import 'telas/Tela_Login.dart';
import 'telas/tela_info_extintor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.light; // Tema padrão inicial é claro

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Carregar a preferência de tema (modo claro/escuro)
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false; // Padrão: claro
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Atualizar o tema globalmente
  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APLICATIVO GESTÃO DE EXTINTORES',
      theme: ThemeData.light(), // Tema claro
      darkTheme: ThemeData.dark(), // Tema escuro
      themeMode: _themeMode, // Tema baseado na preferência do usuário
      initialRoute: '/',
      routes: {
        '/': (context) => TelaLogin(),
        '/scan-qr': (context) => ScannerQRCODE(),
      },
      // Aqui configuramos a rota dinâmica para passar 'patrimonio' como argumento
      onGenerateRoute: (settings) {
        if (settings.name == '/info-extintor') {
          final patrimonio = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => TelaInfoExtintor(patrimonio: patrimonio),
          );
        }
        return null;
      },
    );
  }
}
