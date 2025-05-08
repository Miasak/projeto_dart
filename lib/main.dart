import 'package:flutter/material.dart';
import 'entrada_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App de Produtos',
      debugShowCheckedModeBanner: false,
      home: const EntradaPage(),
    );
  }
}
