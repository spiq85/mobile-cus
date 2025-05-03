import 'package:flutter/material.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late HttpService httpService;
  List<dynamic> items = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    httpService = HttpService(authService: AuthService());
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final data = await httpService.fetchItems();
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Barang')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text('Gagal: $error'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(item['nama_barang'] ?? 'Nama tidak tersedia'),
                        subtitle: Text('Stok: ${item['stok'] ?? '-'}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigasi ke detail jika ada
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
