import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class HttpService {
  static const String baseUrl = 'http://127.0.0.1:8000'; 
  final AuthService authService;

  HttpService({required this.authService});

  Future<Map<String, String>> get headers async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login.');
    }
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<dynamic>> fetchItems() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/items'),
    headers: await headers,
  );
  final jsonData = _processResponse(response);
  if (jsonData['success'] == true) {
    return jsonData['data'];
  } else {
    throw Exception(jsonData['message'] ?? 'Gagal memuat data');
  }
}

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'), headers: await headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchUserDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/$id'), headers: await headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchItemsDetail(int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/items/$id'),
    headers: await headers,
  );

  final jsonData = _processResponse(response);
  if (jsonData['success'] == true) {
    return jsonData['data'];
  } else {
    throw Exception(jsonData['message'] ?? 'Gagal memuat data detail');
  }
}


 Future<List<dynamic>> fetchReturns() async {
    final response = await http.get(Uri.parse('$baseUrl/api/detail-returns'),
        headers: await headers);
    final jsonData = _processResponse(response);

    if (jsonData is Map<String, dynamic> && jsonData['status'] == 'success') {
      return jsonData['data'];
    } else {
      throw Exception('Gagal memuat data pengembalian');
    }
  }

  Future<Map<String, dynamic>> fetchReturnDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/detail-returns/$id'), headers: await headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchDetailBorrows(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrows/$id'), headers: await headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchDetailBorrow(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrows/$id'), headers: await headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchCategoryItems(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories/$id/items'), headers: await headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> fetchCategoryItem(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/categories/$id/items'), headers: await headers);
    return _processResponse(response);
  }

  Future<List<dynamic>> fetchBorrowed() async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrowed'),
        headers: await headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return body['data']; // Ini yang penting: hanya kembalikan List, bukan Map
    } else {
      throw Exception('Gagal memuat data peminjaman');
    }
  }


  Future<Map<String, dynamic>> fetchBorrowedDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrowed/$id'), headers: await headers);
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> createBorrowed(Map<String, dynamic> data) async {
  final requestHeaders = await headers;
  requestHeaders['Content-Type'] = 'application/json';

  final response = await http.post(
    Uri.parse('$baseUrl/api/borrowed'),
    headers: requestHeaders,
    body: jsonEncode(data),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}'); // 🧠 Tambahkan ini untuk lihat detail error Laravel
    throw Exception('Gagal meminjam barang: ${response.body}');
  }
}

Future<Map<String, dynamic>> createDetailReturn({
    required int idBorrowed,
    required String description,
    required String dateReturn,
    File? imageFile,
    Uint8List? webImageBytes,
    String? webImageName,
  }) async {
    final token = await authService.getToken();
    final uri = Uri.parse('$baseUrl/api/detail-returns');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // ✅ Tambahkan semua field yang dibutuhkan oleh backend Laravel
    request.fields['id_borrowed'] = idBorrowed.toString();
    request.fields['description'] = description;
    request.fields['date_return'] = dateReturn;

    // ✅ Tambahkan gambar
    if (kIsWeb && webImageBytes != null && webImageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'item_image',
          webImageBytes,
          filename: webImageName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'item_image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      throw Exception('Gambar tidak ditemukan');
    }

    // ✅ Kirim request dan handle responsenya
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      print('STATUS: ${response.statusCode}');
      print('BODY: $responseBody');
      throw Exception('Gagal mengirim pengembalian: $responseBody');
    }
  }




  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data: ${response.statusCode}');
    }
  }
}
