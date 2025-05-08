import 'package:flutter/material.dart';
import 'produtos_page.dart'; // importa sua página principal

class EntradaPage extends StatefulWidget {
  const EntradaPage({super.key});

  @override
  State<EntradaPage> createState() => _EntradaPageState();
}

class _EntradaPageState extends State<EntradaPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProdutosPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Opa Beleza? oque manda hoje patrão?',
          style: TextStyle(
            fontSize: 24, // Tamanho da fonte
            fontWeight: FontWeight.bold, // Peso (negrito)
            color: Colors.black, // Cor do texto
            letterSpacing: 1.0, // Espaço entre letras
            wordSpacing: 2.0, // Espaço entre palavras
            fontStyle: FontStyle.italic, // Estilo itálico
            //decoration: TextDecoration.underline, // Sublinhado
            //decorationColor: Colors.indigoAccent, // Cor do sublinhado
            //decorationThickness: 2.0 // Espessura do sublinhado
          ),
        ),
      ),
    );
  }
}
