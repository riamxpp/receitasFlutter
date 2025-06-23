import 'package:http/http.dart' as http;
import 'dart:convert'; // Para usar jsonDecode

Future<void> fetchRandomMeal() async {
  final uri = Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php');

  try {
    final response = await http.get(uri);
    print('Status Code da Resposta: ${response.statusCode}');
    print('Corpo da Resposta Bruta: ${response.body}');
    if (response.statusCode == 200) {
      // Decodifica a resposta JSON
      final data = jsonDecode(response.body);
      
      // Imprime o resultado completo no console.
      // A API retorna um mapa com uma chave 'meals' que contém uma lista.
      // O primeiro item dessa lista é a receita aleatória.
      print('Receita Aleatória Recebida:');
      print(data['meals'][0]); 
      
      // Se quiser ver apenas o nome da receita:
      // print('Nome da Receita: ${data['meals'][0]['strMeal']}');

    } else {
      print('Erro na requisição: ${response.statusCode}');
    }
  } catch (e) {
    // Captura e imprime erros de conexão ou outros
    print('Erro de conexão: $e');
  }
}

// Para testar essa função, você pode chamá-la em qualquer lugar assíncrono,
// por exemplo, no initState de um StatefulWidget ou no onPressed de um botão.
//
// Exemplo de como chamar (coloque dentro de um main ou um método assíncrono):
// void main() {
//   fetchRandomMeal(); // Isso fará a chamada ao iniciar o app
// }
//
// Ou em um botão:
// ElevatedButton(
//   onPressed: () {
//     fetchRandomMeal();
//   },
//   child: Text('Buscar Receita Aleatória'),
// )