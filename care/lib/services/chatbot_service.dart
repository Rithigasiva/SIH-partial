import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? "http://localhost:8080";


  Future<String> sendMessage(String message) async {
    final r = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'}
    );
    print(r.body);
    print(r);
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? "No reply";
    } else {
      return "Error: ${response.statusCode}";
    }
  }
}
