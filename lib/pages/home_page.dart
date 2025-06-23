// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para usar jsonDecode

// Importe suas outras páginas depois de criá-las
import 'package:receitas/pages/category_list_page.dart';
// import 'package:receitas/presentation/pages/area_list_page.dart';
// import 'package:receitas/presentation/pages/ingredient_list_page.dart';
// import 'package:receitas/presentation/pages/random_meal_page.dart'; // Se for ter uma página dedicada apenas a isso


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _randomMeal; // Variável para guardar a receita aleatória
  bool _isLoading = true; // Para controlar o indicador de carregamento
  String? _errorMessage; // Para exibir mensagens de erro

  @override
  void initState() {
    super.initState();
    _fetchRandomMeal(); // Chama a função para buscar a receita aleatória ao iniciar a tela
  }

  Future<void> _fetchRandomMeal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpa qualquer erro anterior
    });

    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // A API retorna uma lista de 'meals', mesmo que seja apenas uma.
          _randomMeal = data['meals']?[0]; // Pegamos o primeiro (e único) item da lista
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
        title: const Text('Receitas Deliciosas!'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: <Widget>[
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
              // TODO: Mudar para AreaListPage quando criada
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryListPage()), // Mudar para AreaListPage()
              );
            },
            child: const Text(
              'Áreas',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Mudar para IngredientListPage quando criada
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryListPage()), // Mudar para IngredientListPage()
              );
            },
            child: const Text(
              'Ingredientes',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Mudar para RandomMealPage (se for uma página diferente)
              // Ou, se a receita aleatória já está na Home, este botão pode recarregar.
              _fetchRandomMeal(); // Recarrega uma nova receita aleatória na mesma tela
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
                          onPressed: _fetchRandomMeal, // Tentar buscar novamente
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
              : _randomMeal == null // Se não há erro mas a receita é nula (ex: API retornou vazio)
                  ? const Center(
                      child: Text(
                        'Nenhuma receita aleatória encontrada no momento. Tente novamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView( // Para permitir rolagem se o conteúdo for grande
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Sua Receita Aleatória do Dia!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _randomMeal!['strMeal'] ?? 'Nome da Receita Desconhecido',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Exibindo a imagem da receita
                          _randomMeal!['strMealThumb'] != null && _randomMeal!['strMealThumb'].isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    _randomMeal!['strMealThumb'],
                                    width: MediaQuery.of(context).size.width * 0.8, // 80% da largura da tela
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
                            onPressed: _fetchRandomMeal, // Botão para buscar outra receita aleatória
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
                          // Opcional: Adicionar uma descrição ou instruções curtas
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
                    ),
    );
  }
}