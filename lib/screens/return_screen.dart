import 'package:flutter/material.dart';
import 'package:sisfo_mobile/service/http_service.dart';
import 'package:sisfo_mobile/service/auth_service.dart'; // pastikan ini sesuai path

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  late HttpService httpService;
  late Future<List<dynamic>> _futureReturns;

  @override
  void initState() {
    super.initState();
    final authService =
        AuthService(); // atau ambil dari provider jika kamu pakai state management
    httpService = HttpService(authService: authService);
    _futureReturns = httpService.fetchReturns();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pengembalian Barang'),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _futureReturns,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada data pengembalian.'));
            } else {
              final returns = snapshot.data!;
              return ListView.builder(
                itemCount: returns.length,
                itemBuilder: (context, index) {
                  final item = returns[index];
                  final status = item['status']?.toLowerCase();
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title:
                          Text('Kode: ${item['code_item'] ?? 'Tidak ada'}'),
                      subtitle: Text(
                          'Tanggal: ${item['date_return'] ?? 'Tidak diketahui'}'),
                      trailing: Text(
                        status == 'approved' ? 'Approved' : 'Pending',
                        style: TextStyle(
                          color: status == 'approved'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Navigasi ke halaman detail (opsional)
                      },
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
