import 'package:flutter/material.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ItemsDetailScreen extends StatefulWidget {
  final int itemId;

  const ItemsDetailScreen({super.key, required this.itemId});

  @override
  State<ItemsDetailScreen> createState() => _ItemsDetailScreenState();
}

class _ItemsDetailScreenState extends State<ItemsDetailScreen> {
  late Future<Map<String, dynamic>> _itemDetailFuture;
  final AuthService _authService = AuthService();
  late HttpService _httpService;

  @override
  void initState() {
    super.initState();
    _httpService = HttpService(authService: _authService);
    _itemDetailFuture = _httpService.fetchItemsDetail(widget.itemId);
  }

  Future<void> _pinjamBarang() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin meminjam barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Pinjam'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final result = await _httpService.createBorrowed({
          'item_id': widget.itemId,
          });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Peminjaman berhasil diajukan')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal meminjam: $e')),
        );
      }
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
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

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const SizedBox(
                            height: 200,
                            child: Center(child: Text('Gambar tidak tersedia')),
                          ),
                          imageBuilder: (context, imageProvider) => AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              item['item_name'] ?? 'Nama tidak tersedia',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              FontAwesomeIcons.barcode,
                              'Kode',
                              item['code_items'] ?? '-',
                            ),
                            _buildDetailRow(
                              FontAwesomeIcons.boxesStacked,
                              'Kategori',
                              item['id_category']?['category_name'] ?? '-',
                            ),
                            _buildDetailRow(
                              FontAwesomeIcons.cubes,
                              'Stok',
                              item['stock']?.toString() ?? '0',
                            ),
                            _buildDetailRow(
                              FontAwesomeIcons.tag,
                              'Merek',
                              item['brand'] ?? '-',
                            ),
                            _buildDetailRow(
                              FontAwesomeIcons.circleCheck,
                              'Status',
                              item['status'] ?? '-',
                            ),
                            _buildDetailRow(
                              FontAwesomeIcons.screwdriverWrench,
                              'Kondisi',
                              item['item_condition'] ?? '-',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: _pinjamBarang,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange.shade700, // Lebih terang dari indigo
                    foregroundColor: Colors.white,
                    elevation: 8, // Menambahkan bayangan
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 24),
                  label: const Text(
                    'PINJAM BARANG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
