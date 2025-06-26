// lib/presentation/pages/area_list_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Você pode adicionar a navegação para uma página de receitas por área aqui, similar à CategoryMealsPage
// import 'package:receitas/presentation/pages/area_meals_page.dart'; // Exemplo futuro

class AreaListPage extends StatefulWidget {
  const AreaListPage({super.key});

  @override
  State<AreaListPage> createState() => _AreaListPageState();
}

class _AreaListPageState extends State<AreaListPage> {
  List<dynamic> _areas = [];
  bool _isLoading = true;
  String? _errorMessage;

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

    // Endpoint para listar todas as áreas culinárias
    final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // A API retorna as áreas sob a chave 'meals' para este endpoint
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
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: const Icon(Icons.flag, size: 40, color: Colors.orange), // Ícone genérico para área
                            title: Text(
                              area['strArea'] ?? 'Área Desconhecida',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            onTap: () {
                              // TODO: Implementar navegação para uma página que lista receitas desta área
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Clicou na área: ${area['strArea']}!')),
                              );
                              // Exemplo de navegação futura para AreaMealsPage (similar à CategoryMealsPage):
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => AreaMealsPage(areaName: area['strArea']),
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