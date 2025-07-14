// lib/presentation/pages/area_list_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:receitas/pages/area/area_meal_page.dart';

class AreaListPage extends StatefulWidget {
  const AreaListPage({super.key});

  @override
  State<AreaListPage> createState() => _AreaListPageState();
}

class _AreaListPageState extends State<AreaListPage> {
  List<dynamic> _areas = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Como a API de áreas não fornece imagens nem descrições, vamos simular
  // ou usar placeholders. Para a imagem, usaremos um ícone.
  // Para a descrição, uma frase genérica.
  // Se você tiver uma fonte para imagens de bandeiras ou descrições,
  // pode adaptar este mapa ou buscar de outra forma.
  final Map<String, String> _areaDescriptions = {
    'American': 'A culinária americana é vasta e regional, incluindo pratos como hambúrgueres e costelas.',
    'British': 'Culinária britânica tradicional com foco em carnes assadas, tortas e Fish and Chips.',
    'Canadian': 'Comidas típicas do Canadá, com influências indígenas, francesas e britânicas, como Poutine.',
    'Chinese': 'Uma das culinárias mais antigas e diversificadas do mundo, com sabores e técnicas variados.',
    'Croatian': 'Culinária da Croácia, influenciada por países vizinhos, com frutos do mar e carnes.',
    'Dutch': 'Culinária holandesa, conhecida por queijos, batatas e pratos simples e saborosos.',
    'Egyptian': 'Culinária egípcia com influências do Oriente Médio e Mediterrâneo, rica em vegetais.',
    'French': 'Culinária francesa renomada mundialmente por sua sofisticação e técnicas refinadas.',
    'Greek': 'Culinária grega, baseada em azeite, vegetais frescos, ervas, grãos e pão, com carne e peixe.',
    'Indian': 'Culinária indiana, famosa por seus temperos intensos e uso de legumes, arroz e pão.',
    'Irish': 'Culinária irlandesa, simples e farta, com batatas, carne de cordeiro e ensopados.',
    'Italian': 'A culinária italiana é famosa por suas massas, pizzas, risotos e pratos à base de tomate.',
    'Jamaican': 'Culinária jamaicana com influências africanas, espanholas e indianas, com temperos fortes.',
    'Japanese': 'Culinária japonesa, conhecida por sushi, sashimi e pratos à base de arroz e peixe.',
    'Kenyan': 'Culinária do Quênia, com forte uso de milho, feijão e vegetais, e influência de várias etnias.',
    'Malaysian': 'Culinária malaia, uma fusão de sabores malaios, chineses e indianos.',
    'Mexican': 'A culinária mexicana é famosa por tacos, burritos, quesadillas e pratos picantes.',
    'Moroccan': 'Culinária marroquina, com tagines, cuscuz e uma rica variedade de especiarias.',
    'Polish': 'Culinária polonesa, conhecida por pratos fartos como pierogi, bigos e sopas.',
    'Portuguese': 'Culinária portuguesa, com muitos pratos de bacalhau, frutos do mar e doces.',
    'Russian': 'Culinária russa, com sopas encorpadas, pães, laticínios e pratos com carne.',
    'Spanish': 'Culinária espanhola, famosa por paella, tapas e influências regionais diversas.',
    'Thai': 'Culinária tailandesa, conhecida por seu equilíbrio de sabores doce, azedo, salgado e picante.',
    'Tunisian': 'Culinária tunisiana, com influências mediterrâneas, árabes e francesas, com muitos temperos.',
    'Turkish': 'Culinária turca, rica em carnes grelhadas, pães, iogurtes e doces.',
    'Unknown': 'Área culinária desconhecida ou não especificada.',
    'Vietnamese': 'Culinária vietnamita, com sabores frescos, ervas aromáticas e sopas nutritivas como o Pho.',
  };


  @override
  void initState() {
    super.initState();
    _fetchAreas(); // Inicia a busca pelas áreas ao carregar a página
  }

  Future<void> _fetchAreas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _areas = data['meals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar áreas: ${response.statusCode}';
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
        title: const Text('Áreas Culinárias'),
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
                          onPressed: _fetchAreas,
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
              : _areas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma área culinária encontrada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _areas.length,
                      itemBuilder: (context, index) {
                        final area = _areas[index];
                        final areaName = area['strArea'] ?? 'Área Desconhecida';
                        // A API de áreas não fornece imagem. Usamos um ícone genérico.
                        // Se você tiver uma URL para a bandeira ou símbolo de cada área, pode usar Image.network.
                        const Widget leadingWidget = Icon(Icons.flag, size: 60, color: Colors.orange); 

                        // Tenta buscar a descrição do mapa, ou usa uma genérica
                        final String description = _areaDescriptions[areaName] ?? 'Informações sobre esta área culinária não estão disponíveis.';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AreaMealsPage(
                                  areaName: areaName,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ícone da Área (substitui a imagem da categoria)
                                leadingWidget, // Usamos o ícone ou Image.network se tiver URL
                                const SizedBox(width: 15),

                                // Detalhes da Área (Título e Descrição)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        areaName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        description,
                                        maxLines: 4, // Mesmo número de linhas que na CategoryListPage
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}