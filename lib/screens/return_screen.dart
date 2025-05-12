import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:sisfo_mobile/service/http_service.dart';

class ReturnDetailScreen extends StatelessWidget {
  static const String baseUrl = 'http://127.0.0.1:8000';

  const ReturnDetailScreen({super.key}); 


  // Fetch detail data function
  Future<Map<String, dynamic>> fetchReturnDetail(int id) async {
    try {
      final httpService = HttpService(authService: AuthService());
      final headers = await httpService. headers; 

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$id/comments'),
        headers: headers, // Menambahkan headers pada request
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Mengembalikan data jika berhasil
      } else {
        throw Exception('Failed to load return details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchReturnDetail(1), // Replace 1 with the actual id you want to fetch
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(child: Text('Error fetching details')),
          );
        } else if (snapshot.hasData) {
          var data = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detail Pengembalian'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelas: ${data['class_name']}'),
                  Text('Nama: ${data['user_name']}'),
                  Text('Barang: ${data['item_name']}'),
                  Text('Keperluan: ${data['used_for']}'),
                  Text('Status: ${data['status']}'),
                  Text('Tanggal Pengembalian: ${data['date_return']}'),
                  Text('Deskripsi: ${data['description']}'),
                  const SizedBox(height: 20),
                  const Text('Gambar Barang:'),
                  for (var image in data['item_images'])
                    Image.network(image),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('No Data'),
            ),
            body: const Center(child: Text('No details available')),
          );
        }
      },
    );
  }
}
