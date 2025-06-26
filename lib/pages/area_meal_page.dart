// lib/presentation/pages/area_meals_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Importe a página de detalhes da receita, para quando clicarem em uma receita específica
import 'package:receitas/pages/meal_details_page.dart';


class AreaMealsPage extends StatefulWidget {
  final String areaName; // Receberá o nome da área clicada para filtrar as receitas

  const AreaMealsPage({super.key, required this.areaName});

  @override
  State<AreaMealsPage> createState() => _AreaMealsPageState();
}

class _AreaMealsPageState extends State<AreaMealsPage> {
  List<dynamic> _meals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMealsByArea(); // Inicia a busca pelas receitas da área ao carregar a página
  }

  Future<void> _fetchMealsByArea() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _meals = []; // Limpa a lista antes de uma nova busca
    });

    // Endpoint para filtrar receitas por ÁREA
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?a=${widget.areaName}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // A API retorna a lista de refeições sob a chave 'meals' para este endpoint
          _meals = data['meals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar receitas para ${widget.areaName}: ${response.statusCode}';
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
        title: Text('Receitas ${widget.areaName}'), // Título dinâmico (ex: Receitas American)
        backgroundColor: Colors.orange,
        centerTitle: true,
        leading: IconButton( // Botão de voltar para a página anterior
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
                          onPressed: _fetchMealsByArea, // Tentar buscar novamente
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
                        'Nenhuma receita encontrada para "${widget.areaName}".',
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
                              // Ao clicar em uma receita na lista de áreas, navega para os detalhes da receita
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