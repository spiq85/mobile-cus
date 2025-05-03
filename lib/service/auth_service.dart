import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // sesuaikan dengan IP/host laravel kamu

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    print('Status: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);


      if (data['success'] == true) {
        final token = data['token'];
        

        // Simpan token untuk digunakan nanti
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return true;
      }
    } else {
      print('Login failed: ${response.statusCode} | ${response.body}');
    }

    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
