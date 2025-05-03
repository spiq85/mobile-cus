import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfo_mobile/service/auth_service.dart';

class HttpService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // API Base URL
  final AuthService authService;

  HttpService({required this.authService});

  Future<Map<String, String>> get _headers async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchUserDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$id'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/api/items'),
        headers: await _headers);
    final Map<String, dynamic> json = jsonDecode(response.body);
    return json['data'];
  }

  Future<Map<String, dynamic>> fetchItemDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/posts/$id/items'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchReturns(int id) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$id/comments'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchReturnDetail(int id) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$id/comments'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchDetailBorrows(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrows/$id'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchDetailBorrow(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrows/$id'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchCategoryItems(int id) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/categories/$id/items'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchCategoryItem(int id) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/categories/$id/items'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchBorrowed(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrows/$id/items'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchBorrowedDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrows/$id/items'),
        headers: await _headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> createBorrowed(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/borrowed'),
      headers: await _headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
