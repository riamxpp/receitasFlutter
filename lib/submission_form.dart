// lib/presentation/widgets/recipe_submission_form.dart
import 'package:flutter/material.dart';

class RecipeSubmissionForm extends StatefulWidget {
  const RecipeSubmissionForm({super.key});

  @override
  State<RecipeSubmissionForm> createState() => _RecipeSubmissionFormState();
}

class _RecipeSubmissionFormState extends State<RecipeSubmissionForm> {
  final _formKey = GlobalKey<FormState>(); // Chave para validar o formulário
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void dispose() {
    // Descartar os controladores quando o widget for removido para evitar vazamentos de memória
    _recipeNameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Função para lidar com o envio do formulário (fictício)
  void _submitRecipe() {
    if (_formKey.currentState!.validate()) {
      // Se o formulário é válido, coletar os dados (ficticiamente)
      final String recipeName = _recipeNameController.text;
      // final String ingredients = _ingredientsController.text;
      // final String instructions = _instructionsController.text;
      // final String imageUrl = _imageUrlController.text;

      // Por ser fictício, apenas mostra uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receita $recipeName enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Opcional: Limpar os campos do formulário
      _recipeNameController.clear();
      _ingredientsController.clear();
      _instructionsController.clear();
      _imageUrlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _recipeNameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Receita',
                  hintText: 'Ex: Bolo de Chocolate Cremoso',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.receipt_long),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da receita.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Ingredientes',
                  hintText: 'Ex: 2 ovos, 1 xícara de farinha (separar por vírgulas ou linhas)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.food_bank),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira os ingredientes.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: 'Instruções de Preparo',
                  hintText: 'Ex: Misture os secos, adicione os molhados...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.edit_note),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira as instruções.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL da Imagem (Opcional)',
                  hintText: 'Ex: https://minhafoto.com/receita.jpg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.image),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submitRecipe,
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar Receita'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}