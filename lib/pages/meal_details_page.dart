// lib/presentation/pages/meal_details_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealDetailsPage extends StatefulWidget {
  final String mealId;

  const MealDetailsPage({super.key, required this.mealId});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  Map<String, dynamic>? _mealDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMealDetails();
  }

  Future<void> _fetchMealDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _mealDetails = data['meals']?[0];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar detalhes da receita: ${response.statusCode}';
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

  // Helper para construir a lista de ingredientes e medidas
  List<Widget> _buildIngredientsList(Map<String, dynamic> meal) {
    List<Widget> ingredientsWidgets = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty && ingredient.trim() != '') {
        ingredientsWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.orange), // Ponto de lista estilizado
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$ingredient - ${measure ?? ''}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return ingredientsWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mealDetails?['strMeal'] ?? 'Detalhes da Receita'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white, // Ícones e texto em branco na AppBar
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
                          onPressed: _fetchMealDetails,
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
              : _mealDetails == null
                  ? const Center(
                      child: Text(
                        'Detalhes da receita não encontrados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0), // Padding geral
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome da Receita (Mais Destacado)
                          Text(
                            _mealDetails!['strMeal'] ?? 'Receita Desconhecida',
                            style: const TextStyle(
                              fontSize: 32, // Aumentei o tamanho
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange, // Destaque a cor
                            ),
                            textAlign: TextAlign.left, // Alinhamento à esquerda
                          ),
                          const SizedBox(height: 15),

                          // Imagem da Receita
                          _mealDetails!['strMealThumb'] != null && _mealDetails!['strMealThumb'].isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.network(
                                    _mealDetails!['strMealThumb'],
                                    width: double.infinity, // Ocupa largura total
                                    height: 250,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 250,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 100,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 250,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                                  ),
                                ),
                          const SizedBox(height: 20),

                          // Categoria e Área
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1), // Fundo leve
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_mealDetails!['strCategory'] != null && _mealDetails!['strCategory'].isNotEmpty)
                                  Text(
                                    'Categoria: ${_mealDetails!['strCategory']}',
                                    style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic, color: Colors.black87),
                                  ),
                                if (_mealDetails!['strArea'] != null && _mealDetails!['strArea'].isNotEmpty)
                                  Text(
                                    'Área: ${_mealDetails!['strArea']}',
                                    style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic, color: Colors.black87),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Ingredientes
                          Text(
                            'Ingredientes:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700, // Tom mais escuro de laranja
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[50], // Fundo suave para a lista
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildIngredientsList(_mealDetails!),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Instruções de Preparo
                          Text(
                            'Instruções de Preparo:',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              _mealDetails!['strInstructions'] ?? 'Nenhuma instrução disponível.',
                              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Link para YouTube (se existir)
                          if (_mealDetails!['strYoutube'] != null && _mealDetails!['strYoutube'].isNotEmpty)
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Abrir link do YouTube (requer pacote url_launcher)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Abrir vídeo no YouTube... (implementar url_launcher)')),
                                  );
                                },
                                icon: const Icon(Icons.play_circle_fill),
                                label: const Text('Ver Vídeo de Preparo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700, // Vermelho mais escuro
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
    );
  }
}