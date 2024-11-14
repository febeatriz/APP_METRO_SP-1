import 'package:flutter/material.dart';
import 'telas/Tela_Login.dart';
import 'telas/tela_scan_qr.dart';
import 'telas/tela_info_extintor.dart';
import 'dart:ui_web' as ui; 


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APLICATIVO GESTÃO DE EXTINTORES',
      initialRoute: '/',
      routes: {
        '/': (context) => TelaLogin(),
        '/scan-qr': (context) => TelaScanQR(),
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
