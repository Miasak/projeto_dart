import 'dart:convert';
import 'package:http/http.dart' as http;
import 'produtos_page.dart';

class ProdutoService {
  static const String baseUrl =
      'https://produtos-api-dj2f.onrender.com/produtos';

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
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar produto');
    }
  }
}
