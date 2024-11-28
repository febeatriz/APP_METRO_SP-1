import 'package:mobilegestaoextintores/src/telas/TelaPrincipal.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Configuracao.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Consulta.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Login.dart';
import 'package:flutter/material.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Manutencao.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_RegistrarExtintorManual.dart';

class App extends StatelessWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'APLICATIVO GESTÃO DE EXTINTORES',
      home: Scaffold(
      body: TelaPrincipal(),
      )
    );
  }
}