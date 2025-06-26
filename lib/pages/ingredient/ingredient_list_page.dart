// lib/presentation/pages/ingredient_list_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientListPage extends StatefulWidget {
  const IngredientListPage({super.key});

  @override
  State<IngredientListPage> createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  List<dynamic> _ingredients = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchIngredients(); // Inicia a busca pelos ingredientes ao carregar a página
  }

  Future<void> _fetchIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Endpoint para listar todos os ingredientes
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?i=list');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // A API retorna os ingredientes sob a chave 'meals' para este endpoint
          _ingredients = data['meals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar ingredientes: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredientes Principais'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: IconButton( // Botão de voltar para a página anterior
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchIngredients,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _ingredients.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum ingrediente encontrado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = _ingredients[index];
                        // A API TheMealDB não fornece imagens para os ingredientes diretamente nesta lista,
                        // mas fornece a URL para um ícone ou imagem (se você precisar).
                        // O formato do ícone seria: 'https://www.themealdb.com/images/ingredients/${ingredient['strIngredient']}.png'
                        final String? imageUrl = ingredient['strIngredient'] != null && ingredient['strIngredient'].isNotEmpty
                            ? 'https://www.themealdb.com/images/ingredients/${ingredient['strIngredient']}-small.png'
                            : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.food_bank, size: 40, color: Colors.grey),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(Icons.food_bank, size: 40, color: Colors.orange), // Ícone genérico para ingrediente
                            title: Text(
                              ingredient['strIngredient'] ?? 'Ingrediente Desconhecido',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: ingredient['strDescription'] != null && ingredient['strDescription'].isNotEmpty
                                ? Text(
                                    ingredient['strDescription'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  )
                                : null,
                            onTap: () {
                              // TODO: Implementar navegação para uma página que lista receitas com este ingrediente
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Clicou no ingrediente: ${ingredient['strIngredient']}!')),
                              );
                              // Exemplo de navegação futura para IngredientMealsPage:
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => IngredientMealsPage(ingredientName: ingredient['strIngredient']),
                              //   ),
                              // );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}