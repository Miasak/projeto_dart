import 'package:flutter/material.dart';
import 'produtos_service.dart';

class Produto {
  final int? id;
  final String nome;
  final double preco;
  final int quantidade;

  Produto({
    this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
      quantidade: (json['quantidade'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nome': nome, 'preco': preco, 'quantidade': quantidade};
  }
}

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({Key? key}) : super(key: key);

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() {
    setState(() {
      _produtosFuture = ProdutoService.getProdutos();
    });
  }

  void _mostrarDialogoProduto({Produto? produtoExistente}) {
    final nomeController = TextEditingController(
      text: produtoExistente?.nome ?? '',
    );
    final precoController = TextEditingController(
      text: produtoExistente?.preco.toString() ?? '',
    );
    final quantidadeController = TextEditingController(
      text: produtoExistente?.quantidade.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              produtoExistente == null ? 'Novo Produto' : 'Editar Produto',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: precoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Preço'),
                ),
                TextField(
                  controller: quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantidade'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 212, 240),
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () async {
                  final nome = nomeController.text;
                  final preco = double.tryParse(precoController.text) ?? 0.0;
                  final quantidade =
                      int.tryParse(quantidadeController.text) ?? 0;

                  if (nome.isEmpty || preco <= 0 || quantidade <= 0) {
                    // mostrar alerta ou retornar sem salvar
                    return;
                  }

                  if (produtoExistente == null) {
                    await ProdutoService.addProduto(
                      Produto(nome: nome, preco: preco, quantidade: quantidade),
                    );
                  } else {
                    await ProdutoService.updateProduto(
                      Produto(
                        id: produtoExistente.id,
                        nome: nome,
                        preco: preco,
                        quantidade: quantidade,
                      ),
                    );
                  }

                  Navigator.pop(context);
                  _carregarProdutos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        produtoExistente == null
                            ? 'Produto adicionado com Sucesso!'
                            : 'Produto atualizado com Sucesso!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(produtoExistente == null ? 'Adicionar' : 'Editar'),
              ),
            ],
          ),
    );
  }

  void _confirmarExclusao(int id) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Deseja realmente excluir este produto?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 235, 19, 19),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext); // Fecha o diálogo

                  await ProdutoService.deleteProduto(id); // Aguarda exclusão

                  if (!mounted) return;

                  // ✅ Força recriação do Future e atualização da UI
                  setState(() {
                    _produtosFuture =
                        ProdutoService.getProdutos(); // Força rebuild
                  });

                  // ✅ Pequeno delay para garantir o rebuild visual (opcional)
                  await Future.delayed(const Duration(milliseconds: 100));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produto excluído com sucesso!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },

                child: const Text('Excluir'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loja do seu Zé')),
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          final produtos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              _carregarProdutos();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produto.nome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Preço: R\$ ${produto.preco.toStringAsFixed(2)}',
                                ),
                                Text('Quantidade: ${produto.quantidade}'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                onPressed:
                                    () => _mostrarDialogoProduto(
                                      produtoExistente: produto,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _confirmarExclusao(produto.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoProduto(),
        backgroundColor: const Color.fromARGB(255, 0, 217, 255),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
