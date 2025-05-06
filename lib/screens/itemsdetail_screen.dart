import 'package:flutter/material.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Impor package cached_network_image

class ItemsDetailScreen extends StatefulWidget {
  final int itemId;

  const ItemsDetailScreen({super.key, required this.itemId});

  @override
  State<ItemsDetailScreen> createState() => _ItemsDetailScreenState();
}

class _ItemsDetailScreenState extends State<ItemsDetailScreen> {
  late Future<Map<String, dynamic>> _itemDetailFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _itemDetailFuture =
        HttpService(authService: _authService).fetchItemsDetail(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: Colors.black87,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _itemDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final item = snapshot.data!;
          final baseUrl = 'http://127.0.0.1:8000';
          final imageUrl = item['item_image'] != null
              ? '$baseUrl${item['item_image']}'
              : null;


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  item['item_name'] ?? 'Nama tidak tersedia',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kode: ${item['code_items'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kategori: ${item['id_category']?['category_name'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stok: ${item['stock']?.toString() ?? '0'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Merek: ${item['brand'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${item['status'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kondisi: ${item['item_condition'] ?? '-'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
