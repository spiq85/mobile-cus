import 'package:flutter/material.dart';
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Peminjaman Barang'),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          centerTitle: true,
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
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title:
                          Text('Kode: ${item['id_borrowed'] ?? 'Tidak ada'}'),
                      subtitle: Text('Tanggal: ${item['id_details_borrow']['date_borrowed'] ?? '-'}'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
