import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/TelaScanQR.dart';
import 'telas/Tela_Login.dart';
import 'telas/tela_info_extintor.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APLICATIVO GESTÃO DE EXTINTORES',
      initialRoute: '/scan-qr',
      // routes: {
      //   '/': (context) => TelaLogin(),
      //   '/scan-qr': (context) => ScannerQRCODE(),
      // },
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
