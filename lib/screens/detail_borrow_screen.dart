import 'package:flutter/material.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart';
import 'return_request_screen.dart'; // Import halaman tujuan navigasi

class DetailBorrowScreen extends StatefulWidget {
  final int id;

  const DetailBorrowScreen({super.key, required this.id});

  @override
  State<DetailBorrowScreen> createState() => _DetailBorrowScreenState();
}

class _DetailBorrowScreenState extends State<DetailBorrowScreen> {
  late HttpService httpService;
  late Future<Map<String, dynamic>> _futureDetail;

  static const String baseUrl = 'http://127.0.0.1:8000'; // Ganti sesuai server

  final Map<String, Map<String, dynamic>> fieldMapping = {
    'id_borrowed': {
      'label': 'ID Peminjaman',
      'icon': Icons.bookmark,
      'show': true
    },
    'Nama Barang': {
      'label': 'Nama Barang',
      'icon': Icons.category,
      'show': true
    },
    'Kode Item': {'label': 'Kode Barang', 'icon': Icons.qr_code, 'show': true},
    'Kategori': {
      'label': 'Kategori',
      'icon': Icons.category_outlined,
      'show': true
    },
    'Brand': {'label': 'Merek', 'icon': Icons.business, 'show': true},
    'Kondisi': {
      'label': 'Kondisi',
      'icon': Icons.health_and_safety,
      'show': true
    },
    'created_at': {
      'label': 'Tanggal Dibuat',
      'icon': Icons.date_range,
      'show': false
    },
    'updated_at': {
      'label': 'Tanggal Diperbarui',
      'icon': Icons.update,
      'show': false
    },
  };

  String getFieldLabel(String field) => fieldMapping[field]?['label'] ?? field;
  IconData getFieldIcon(String field) =>
      fieldMapping[field]?['icon'] ?? Icons.inventory;
  bool shouldShowField(String field) => fieldMapping[field]?['show'] ?? true;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    httpService = HttpService(authService: authService);
    _futureDetail = httpService.fetchBorrowedDetail(widget.id);
  }

  Widget buildDetailTile(String key, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: ListTile(
        leading: Icon(getFieldIcon(key), color: Colors.blueAccent),
        title: Text(getFieldLabel(key),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['data'] == null) {
            return const Center(child: Text('Data tidak ditemukan.'));
          } else {
            final data = snapshot.data!['data'];
            final idBorrowed = data['id_borrowed']?.toString() ?? '-';
            final userName = data['id_user']?['name']?.toString() ?? '-';
            final status = data['status']?.toString().toUpperCase() ?? '-';

            final detailsBorrow = data['id_details_borrow'];
            final Map<String, dynamic> itemData =
                detailsBorrow != null && detailsBorrow['id_items'] != null
                    ? Map<String, dynamic>.from(detailsBorrow['id_items'])
                    : {};

            String? imageUrl;
            if (itemData['item_image'] != null) {
              imageUrl = '$baseUrl${itemData['item_image']}';
            }

            Map<String, dynamic> displayData = {
              'id_borrowed': idBorrowed,
              ...itemData,
            };
            displayData.remove('id_items');
            displayData.remove('image');

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildDetailTile('id_borrowed', idBorrowed),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    elevation: 2,
                    child: ListTile(
                      leading:
                          const Icon(Icons.person, color: Colors.blueAccent),
                      title: const Text('Nama User',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          Text(userName, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (imageUrl != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        imageUrl,
                        height: 250,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            height: 250,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        (progress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: 250,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.error_outline,
                                      size: 40, color: Colors.red),
                                  SizedBox(height: 8),
                                  Text('Gambar tidak dapat dimuat',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    'Detail Barang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  ...displayData.entries
                      .where((entry) => shouldShowField(entry.key))
                      .map((entry) =>
                          buildDetailTile(entry.key, entry.value.toString()))
                      .toList(),

                  const SizedBox(height: 16),

                  Card(
                    color: status == 'APPROVED'
                        ? Colors.green[50]
                        : Colors.orange[50],
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      leading: Icon(Icons.info,
                          color: status == 'APPROVED'
                              ? Colors.green
                              : Colors.orange),
                      title: const Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        status,
                        style: TextStyle(
                          color: status == 'APPROVED'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ✅ Tombol Ajukan Pengembalian
                  ElevatedButton.icon(
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('Ajukan Pengembalian'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailReturnScreen(itemId: widget.id),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
