import 'package:flutter/material.dart';

import 'home_screen.dart';

// Iniciando a aplicação com a classe 'MinhaAgenda'
void main() {
  runApp(
    const MinhaAgenda(),
  );
}

// Classe da app 'MinhaAgenda' que inicia a tela 'HomeScreen()'
class MinhaAgenda extends StatelessWidget {
  const MinhaAgenda({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Decide se mostra o banner de depuração de código no app
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
