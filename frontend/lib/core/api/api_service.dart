import 'dart:convert';
import 'dart:io' as io;
import 'package:http/http.dart' as http;

class ApiService {
  
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 [DESKTOP MODE] Tentative de connexion...');
      print('📧 Email: $email');
      print('🌐 URL: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'http://localhost:3000', // Important pour le cors
        },
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Réponse: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Connexion réussie!');
        print('👤 User: ${data['user']?['name']} (${data['user']?['role']})');
        print('🔑 Token reçu: ${data['token'] != null ? "OUI" : "NON"}');
        return data;
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        String errorMessage = 'Erreur ${response.statusCode}';
        
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          errorMessage = 'Réponse: ${response.body}';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('🔥 Exception: $e');
      print('🔥 Type: ${e.runtimeType}');
      
      // Messages d'erreur spécifiques
      if (e.toString().contains('Connection refused')) {
        throw Exception('Backend non accessible sur localhost:3000\nVérifiez que le backend est démarré.');
      }
      if (e.toString().contains('SocketException')) {
        throw Exception('Erreur réseau. Vérifiez votre connexion.');
      }
      
      rethrow;
    }
  }

  // Test de connexion
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🧪 Test connexion backend...');
      print('🌐 URL: $baseUrl/health');
      
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Backend accessible!');
        print('✅ Message: ${data['message']}');
        return data;
      } else {
        throw Exception('Backend erreur ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Test échoué: $e');
      print('💡 Vérifiez que:');
      print('   1. Le backend tourne: cd backend && npm start');
      print('   2. Testez avec: curl http://localhost:3000/api/health');
      throw Exception('Impossible de joindre le backend: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Token invalide');
      }
    } catch (e) {
      throw Exception('Erreur vérification: $e');
    }
  }
}