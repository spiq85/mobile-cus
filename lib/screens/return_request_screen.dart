import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sisfo_mobile/service/auth_service.dart';
import 'package:sisfo_mobile/service/http_service.dart';


class DetailReturnScreen extends StatefulWidget {
  final int itemId;

  const DetailReturnScreen({super.key, required this.itemId});

  @override
  State<DetailReturnScreen> createState() => _DetailReturnScreenState();
}

class _DetailReturnScreenState extends State<DetailReturnScreen> {
  final _descriptionController = TextEditingController();
  final _dateReturnController = TextEditingController();

  File? _itemImage;
  Uint8List? _webImageBytes;
  String? _webImageName;

  bool _isLoading = false;

  final AuthService _authService = AuthService();
  late final HttpService _httpService;

  @override
  void initState() {
    super.initState();
    _httpService = HttpService(authService: _authService);
  }

  // Fungsi pilih gambar
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _webImageName = pickedFile.name;
        });
      } else {
        setState(() {
          _itemImage = File(pickedFile.path);
        });
      }
    }
  }

  // Fungsi konversi gambar ke Base64
  Future<String> _convertImageToBase64() async {
    if (kIsWeb && _webImageBytes != null) {
      return base64Encode(_webImageBytes!);
    } else if (_itemImage != null) {
      final bytes = await _itemImage!.readAsBytes();
      return base64Encode(bytes);
    }
    throw Exception('Gambar tidak ditemukan');
  }

  // Fungsi kirim data ke API menggunakan createDetailReturn
  Future<void> _submitReturn() async {
    if (_itemImage == null && _webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _httpService.createDetailReturn(
        idBorrowed: widget.itemId,
        imageFile: _itemImage,
        webImageBytes: _webImageBytes,
        webImageName: _webImageName,
         description: _descriptionController.text.trim(), // ✅ TAMBAHKAN INI
        dateReturn: _dateReturnController.text.trim(), 
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mengirim gambar pengembalian')),
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
    _descriptionController.dispose();
    _dateReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickedFileName = kIsWeb
        ? (_webImageName ?? '')
        : (_itemImage != null ? path.basename(_itemImage!.path) : '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengembalian Barang'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deskripsi Pengembalian',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Barang tidak rusak...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tanggal Pengembalian'),
            const SizedBox(height: 8),
            TextField(
              controller: _dateReturnController,
              decoration: InputDecoration(
                hintText: 'Contoh: 2025-05-13',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pickedFileName.isNotEmpty
                      ? 'Gambar dipilih: $pickedFileName'
                      : 'Klik untuk memilih gambar',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitReturn,
                    child: const Text('Kirim Pengembalian'),
                  ),
          ],
        ),
      ),
    );
  }
}
