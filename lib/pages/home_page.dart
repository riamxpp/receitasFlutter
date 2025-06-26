// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:receitas/pages/category/category_list_page.dart';
import 'package:receitas/pages/area/area_list_page.dart';
import 'package:receitas/pages/ingredient/ingredient_list_page.dart';
import 'package:receitas/submission_form.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _randomMeal;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRandomMeal();
  }

  @override
  void dispose() {
    // Não precisamos mais descartar os controladores do formulário aqui,
    // pois eles agora estão no RecipeSubmissionForm
    super.dispose();
  }

  Future<void> _fetchRandomMeal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _randomMeal = data['meals']?[0];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar receita aleatória: ${response.statusCode}';
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Receitas Deliciosas!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoryListPage()),
                    );
                  },
                  child: const Text(
                    'Categorias',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AreaListPage()),
                    );
                  },
                  child: const Text(
                    'Áreas',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IngredientListPage()),
                    );
                  },
                  child: const Text(
                    'Ingredientes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _fetchRandomMeal();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Buscando nova receita aleatória...')),
                    );
                  },
                  child: const Text(
                    'Aleatória',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Seção da Receita Aleatória
            const Text(
              'Sua Receita Aleatória do Dia!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _isLoading
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
                                onPressed: _fetchRandomMeal,
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
                    : _randomMeal == null
                        ? const Center(
                            child: Text(
                              'Nenhuma receita aleatória encontrada no momento. Tente novamente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                _randomMeal!['strMeal'] ?? 'Nome da Receita Desconhecido',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              _randomMeal!['strMealThumb'] != null && _randomMeal!['strMealThumb'].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        _randomMeal!['strMealThumb'],
                                        width: MediaQuery.of(context).size.width * 0.8,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.broken_image,
                                          size: 150,
                                          color: Colors.grey,
                                        ),
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
                                  : const Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: _fetchRandomMeal,
                                icon: const Icon(Icons.shuffle),
                                label: const Text('Ver Outra Receita Aleatória'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_randomMeal!['strInstructions'] != null && _randomMeal!['strInstructions'].isNotEmpty)
                                const Text(
                                  'Instruções (Resumo):',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 2),
                                ),
                              Text(
                                _randomMeal!['strInstructions']?.split('\n').first ?? 'Sem instruções disponíveis.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
            const SizedBox(height: 50),

            // Seção do Formulário (AGORA COMO UM WIDGET SEPARADO)
            const Text(
              'Envie Sua Própria Receita!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const RecipeSubmissionForm(), // Usando o novo widget aqui!
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}