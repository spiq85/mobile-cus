import 'package:flutter/material.dart';
import 'package:sisfo_mobile/screens/itemlist_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Beranda'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan pilih menu di bawah untuk melanjutkan:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
                children: [
                  _buildMenuCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Lihat Barang',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const ItemListScreen()));
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.add_shopping_cart_outlined,
                    title: 'Pinjam Barang',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.assignment_return_outlined,
                    title: 'Pengembalian',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Riwayat',
                    color: Colors.deepPurple,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
