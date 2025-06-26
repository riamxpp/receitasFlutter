// lib/presentation/pages/ingredient_meals_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:receitas/pages/meal_details_page.dart';


class IngredientMealsPage extends StatefulWidget {
  final String ingredientName; // Receberá o nome do ingrediente clicado

  const IngredientMealsPage({super.key, required this.ingredientName});

  @override
  State<IngredientMealsPage> createState() => _IngredientMealsPageState();
}

class _IngredientMealsPageState extends State<IngredientMealsPage> {
  List<dynamic> _meals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMealsByIngredient(); // Inicia a busca pelas receitas com o ingrediente
  }

  Future<void> _fetchMealsByIngredient() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _meals = []; // Limpa a lista antes de uma nova busca
    });

    // Endpoint para filtrar receitas por ingrediente
    // A API TheMealDB usa '%20' para espaços em URLs, mas Uri.parse já lida com isso.
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?i=${widget.ingredientName}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // A API retorna a lista de refeições sob a chave 'meals'.
          // Pode ser null se não houver resultados para o ingrediente.
          _meals = data['meals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar receitas com ${widget.ingredientName}: ${response.statusCode}';
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
        title: Text('Receitas com ${widget.ingredientName}'), // Título dinâmico
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: IconButton( // Botão de voltar na AppBar
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volta para a tela anterior
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
                          onPressed: _fetchMealsByIngredient, // Tentar novamente
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
              : _meals.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma receita encontrada com "${widget.ingredientName}".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _meals.length,
                      itemBuilder: (context, index) {
                        final meal = _meals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: meal['strMealThumb'] != null && meal['strMealThumb'].isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      meal['strMealThumb'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
                                    ),
                                  )
                                : const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                            title: Text(
                              meal['strMeal'] ?? 'Nome da Receita Desconhecido',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('ID: ${meal['idMeal']}'),
                            onTap: () {
                              // Navegar para a tela de detalhes da receita
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealDetailsPage(
                                    mealId: meal['idMeal'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}