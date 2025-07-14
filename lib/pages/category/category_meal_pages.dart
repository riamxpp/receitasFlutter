// lib/presentation/pages/category_meals_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:receitas/pages/meal_details_page.dart';

class CategoryMealsPage extends StatefulWidget {
  final String categoryName;

  const CategoryMealsPage({super.key, required this.categoryName});

  @override
  State<CategoryMealsPage> createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  List<dynamic> _meals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMealsByCategory();
  }

  Future<void> _fetchMealsByCategory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _meals = [];
    });

    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.categoryName}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _meals = data['meals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar receitas para ${widget.categoryName}: ${response.statusCode}';
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
        title: Text('Receitas de ${widget.categoryName}'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: IconButton(
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
                          onPressed: _fetchMealsByCategory,
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
                        'Nenhuma receita encontrada para "${widget.categoryName}".',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : LayoutBuilder( // Usamos LayoutBuilder para responsividade
                      builder: (context, constraints) {
                        // Define o número de colunas com base na largura disponível
                        final double minItemWidth = 180; // Largura mínima para cada item
                        final int crossAxisCount = (constraints.maxWidth / minItemWidth).floor().clamp(1, 3); // Entre 1 e 3 colunas

                        return GridView.builder(
                          padding: const EdgeInsets.all(12), // Padding geral da grid
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12, // Espaçamento horizontal entre os cards
                            mainAxisSpacing: 12, // Espaçamento vertical entre os cards
                            childAspectRatio: 0.75, // Ajuste para a proporção largura/altura dos cards
                          ),
                          itemCount: _meals.length,
                          itemBuilder: (context, index) {
                            final meal = _meals[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MealDetailsPage(
                                      mealId: meal['idMeal'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10), // Bordas arredondadas para o container
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2), // Sombra mais sutil
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os filhos na largura
                                  children: [
                                    // Imagem da Receita
                                    Expanded(
                                      flex: 3, // Dá mais espaço para a imagem
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)), // Bordas arredondadas apenas no topo
                                        child: meal['strMealThumb'] != null && meal['strMealThumb'].isNotEmpty
                                            ? Image.network(
                                                meal['strMealThumb'],
                                                fit: BoxFit.cover, // Cobrirá o espaço disponível
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
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
                                            : const Icon(Icons.restaurant_menu, size: 60, color: Colors.grey),
                                      ),
                                    ),
                                    
                                    // Nome da Receita
                                    Expanded(
                                      flex: 1, // Dá menos espaço para o texto
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza o texto
                                          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente o texto
                                          children: [
                                            Text(
                                              meal['strMeal'] ?? 'Nome da Receita Desconhecido',
                                              textAlign: TextAlign.center,
                                              maxLines: 2, // Limita a 2 linhas
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600, // Um pouco menos bold que "bold"
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4), // Espaço entre nome e ID
                                            Text(
                                              'ID: ${meal['idMeal']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}