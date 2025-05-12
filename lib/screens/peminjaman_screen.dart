import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:sisfo_mobile/service/http_service.dart';

class PeminjamanScreen extends StatefulWidget {
  final int itemId;

  const PeminjamanScreen({super.key, required this.itemId});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  final _classController = TextEditingController();

  DateTime? _borrowDate;
  DateTime? _dueDate;

  final AuthService _authService = AuthService();
  late HttpService _httpService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _httpService = HttpService(authService: _authService);
  }

  Future<void> _pickDate({
    required bool isBorrowDate,
  }) async {
    final initialDate = DateTime.now();
    final firstDate = initialDate.subtract(const Duration(days: 0));
    final lastDate = DateTime(initialDate.year + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isBorrowDate) {
          _borrowDate = picked;
          if (_dueDate != null && _dueDate!.isBefore(picked)) {
            _dueDate = picked;
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _submitPeminjaman() async {
    final note = _noteController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());
    final classText = _classController.text.trim();

    if (note.isEmpty || amount == null || amount < 1 || classText.isEmpty || _borrowDate == null || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data peminjaman')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _httpService.createBorrowed({
        'id_items': widget.itemId,
        'used_for': note,
        'amount': amount,
        'class': classText,
        'date_borrowed': DateFormat('yyyy-MM-dd').format(_borrowDate!),
        'due_date': DateFormat('yyyy-MM-dd').format(_dueDate!),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Berhasil mengajukan peminjaman')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keperluan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Untuk praktik...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Jumlah Barang'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 1',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Kelas'),
            const SizedBox(height: 8),
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                hintText: 'Contoh: XII RPL 1',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tanggal Pinjam'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pickDate(isBorrowDate: true),
              child: Text(_borrowDate == null
                  ? 'Pilih Tanggal'
                  : DateFormat('dd MMM yyyy').format(_borrowDate!)),
            ),
            const SizedBox(height: 16),
            const Text('Tanggal Kembali'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pickDate(isBorrowDate: false),
              child: Text(_dueDate == null
                  ? 'Pilih Tanggal'
                  : DateFormat('dd MMM yyyy').format(_dueDate!)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitPeminjaman,
                icon: const Icon(Icons.send),
                label: Text(_isLoading ? 'Mengirim...' : 'Ajukan Peminjaman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
