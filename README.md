App basico para listagem de Produtos

#Descrição:

App simples de carregamento de api com produtos sendo listados separadamente em containers cada um com 
seu nome, preço e quantidade com funções basicas de visualização, criação, edição e delete de predutos.
O applicativo foi pensado com o conseito de gerenciar produtos de estoque.  

#Funcionalidades
Uma tela simples de entrada

Lista de Produtos: A tela principal exibe uma lista de produtos com nome, preço e quantidade.

Adicionar Produto: O usuário pode adicionar um novo produto, fornecendo nome, preço e quantidade.

Editar Produto: Permite editar as informações de um produto existente.

Excluir Produto: O usuário pode excluir um produto da lista.


#main.dart
Esse é o arquivo principal do app, onde tudo começa. Aqui, o app é inicializado com o widget MyApp que, por sua vez, chama a tela de entrada (EntradaPage).

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

Função runApp:
Essa função inicializa o Flutter e diz ao aplicativo qual widget será o ponto de entrada. Nesse caso, o widget MyApp.

MyApp Widget:
Este widget define o tema global e a navegação inicial do app. Ele configura a tela inicial para ser a EntradaPage.


#produtos_page.dart
Essa página é a principal do app, onde as formataçoes de como os produtos são listados, editados ou excluídos.

Essa classe define o modelo de dados de um produto e tem métodos para converter os dados entre o formato JSON e o formato de objeto Dart.

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

Produto:
A classe define o que é um produto no app. Um produto possui id, nome, preco e quantidade.

fromJson():
Método de fábrica que cria um objeto Produto a partir de um mapa JSON (como o recebido da API).

toJson():
Método que converte o objeto Produto de volta para o formato JSON para enviar à API (quando adicionamos ou editamos um produto).


import 'package:flutter/material.dart';
import 'produtos_service.dart';

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
_produtosFuture:
Aqui é definida uma variável que irá armazenar a lista de produtos. Usamos um Future porque os dados vêm de uma API, que pode demorar para carregar.

_carregarProdutos():
Método que chama a função getProdutos da classe ProdutoService, que vai buscar os produtos na API.

void _mostrarDialogoProduto({Produto? produtoExistente}) {
    final nomeController = TextEditingController(text: produtoExistente?.nome ?? '');
    final precoController = TextEditingController(text: produtoExistente?.preco.toString() ?? '');
    final quantidadeController = TextEditingController(text: produtoExistente?.quantidade.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(produtoExistente == null ? 'Novo Produto' : 'Editar Produto'),
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
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nome = nomeController.text;
              final preco = double.tryParse(precoController.text) ?? 0.0;
              final quantidade = int.tryParse(quantidadeController.text) ?? 0;

              if (nome.isEmpty || preco <= 0 || quantidade <= 0) {
                // mostrar alerta ou retornar sem salvar
                 return;
              }

              if (produtoExistente == null) {
                await ProdutoService.addProduto(Produto(nome: nome, preco: preco, quantidade: quantidade));
              } else {
                await ProdutoService.updateProduto(
                  Produto(id: produtoExistente.id, nome: nome, preco: preco, quantidade: quantidade),
                );
              }

              Navigator.pop(context);
              _carregarProdutos();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(produtoExistente == null
                  ? 'Produto adicionado com Sucesso!'
                  : 'Produto atualizado com Sucesso!'),
                  duration: const Duration(seconds: 2)
              )
              );
            },
            child: Text(produtoExistente == null 
            ? 'Adicionar' 
            : 'Editar'),
          ),
        ],
      ),
    );
  }
_mostrarDialogoProduto():
Exibe um diálogo para criar ou editar um produto. Se um produto existente for passado como parâmetro, ele preenche os campos do formulário com os dados desse produto.

void _confirmarExclusao(int id) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: const Text('Deseja realmente excluir este produto?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 235, 19, 19),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await ProdutoService.deleteProduto(id);

            if (mounted) {
              Navigator.pop(context); 
              _carregarProdutos(); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produto excluído com sucesso!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
}
_confirmarExclusao():
Exibe um diálogo pedindo confirmação para excluir um produto. Se confirmado, a função deleteProduto é chamada para remover o produto da API.

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
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
              return ListTile(
                title: Text(produto.nome),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                    Text('Quantidade: ${produto.quantidade}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      ),
                      onPressed: () => _mostrarDialogoProduto(produtoExistente: produto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 19, 19),
                      foregroundColor: Colors.white,
                      ),
                      onPressed: () => _confirmarExclusao(produto.id!),
                    ),
                   ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoProduto(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
FutureBuilder:
Esse widget constrói a interface de acordo com o estado do Future. Ele aguarda os produtos serem carregados e os exibe na tela. Enquanto carrega, ele mostra um CircularProgressIndicator, e se ocorrer um erro, ele exibe uma mensagem de erro.

#produto_service.dart
Essa classe é responsável por fazer as requisições HTTP à API para buscar, adicionar, editar ou excluir produtos.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'produtos_page.dart';

class ProdutoService {
  
  static const String baseUrl = 'https://produtos-api-dj2f.onrender.com/produtos';

  static Future<List<Produto>> getProdutos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Produto.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar produtos');
    }
  }

  static Future<void> addProduto(Produto produto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produto.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao adicionar produto');
    }
  }

  static Future<void> updateProduto(Produto produto) async {
    if (produto.id == null) throw Exception('Produto sem ID');

    final response = await http.put(
      Uri.parse('$baseUrl/${produto.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(produto.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao atualizar produto');
    }
  }

  static Future<void> deleteProduto(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar produto');
    }
  }
}
getProdutos():
Faz uma requisição GET à API para buscar todos os produtos. Se a resposta for bem-sucedida (statusCode == 200), ela decodifica os dados e retorna uma lista de objetos Produto.

addProduto():
Faz uma requisição POST para adicionar um novo produto. O corpo da requisição contém os dados do produto em formato JSON.

updateProduto():
Faz uma requisição PUT para atualizar um produto existente. Ela inclui o id do produto na URL da requisição.

deleteProduto():
Faz uma requisição DELETE para excluir um produto da API, usando o id para especificar qual produto será removido.


A estrutura tá organizada com:
Uma tela simples de entrada
Uma tela principal onde rola toda a mágica com os produtos.
Um serviço separado que cuida da conversa com a API (deixando o código mais limpo).
E um modelo de dados que transforma JSON em objeto e vice-versa, sem dor de cabeça.
Esse tipo de app é ótimo pra quem tá começando ou pra quem quer ter uma base pronta pra projetos maiores. E olha, com uns ajustes, dá pra expandir fácil: colocar login, salvar imagem do produto, estilizar mais o visual e até integrar com banco local.

No fim das contas, é um exemplo claro de como organizar um app Flutter de forma prática e funcional. E o mais legal? Tá tudo prontinho pra você evoluir do jeito que quiser!

