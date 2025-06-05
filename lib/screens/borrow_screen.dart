import 'package:flutter/material.dart';
import 'package:sisfo_mobile/screens/detail_borrow_screen.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  late HttpService httpService;
  late Future<List<dynamic>> _futureBorroweds;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    httpService = HttpService(authService: authService);
    _futureBorroweds = httpService.fetchBorrowed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Barang'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureBorroweds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data peminjaman.'));
          } else {
            final borroweds = snapshot.data!;
            return ListView.builder(
              itemCount: borroweds.length,
              itemBuilder: (context, index) {
                final item = borroweds[index];
                final code = item['id_details_borrow']['id_items']
                        ['code_items'] ??
                    'Tidak ada';
                final date = item['id_details_borrow']['date_borrowed'] ?? '-';
                final status = item['status']?.toLowerCase();
                final id = item['id_borrowed']; // ambil id peminjaman

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Kode: $code'),
                    subtitle: Text('Tanggal: $date'),
                    trailing: Text(
                      status == 'approved' ? 'Approved' : 'Pending',
                      style: TextStyle(
                        color:
                            status == 'approved' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailBorrowScreen(id: id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
