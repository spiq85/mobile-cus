import 'package:flutter/material.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:sisfo_mobile/screens/itemsdetail_screen.dart';

class ItemListScreen extends StatefulWidget {
  final int id;
  const ItemListScreen({super.key, this.id = 0});

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
      final data = widget.id != 0
          ? await httpService.fetchCategoryItems(widget.id)
          : await httpService.fetchItems();

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
                    final itemId = item['id_items'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(item['item_name'] ?? 'Nama tidak tersedia'),
                        subtitle: Text(
                          'Stok: ${item['stock'] ?? '-'} | Kategori: ${item['id_category']?['category_name'] ?? '-'}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (itemId != null && itemId is int) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemsDetailScreen(itemId: itemId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID barang tidak valid')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
