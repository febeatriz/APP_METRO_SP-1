import 'package:mobilegestaoextintores/src/telas/TelaExibirQRCODE.dart';
import 'package:mobilegestaoextintores/src/telas/Tela_Login.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget{
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'APLICATIVO GESTÃO DE EXTINTORES',
      home: Scaffold(
      body: TelaExibirQRCODE(),
      )
    );
  }
}