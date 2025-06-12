import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../models/cake.dart';

class AddEditCakeScreen extends StatefulWidget {
  final Cake? cake;
  const AddEditCakeScreen({super.key, this.cake});

  @override
  State<AddEditCakeScreen> createState() => _AddEditCakeScreenState();
}

class _AddEditCakeScreenState extends State<AddEditCakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  XFile? _imageFile;
  String? _networkImageUrl;
  bool _isLoading = false;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.cake != null) {
      _nameController.text = widget.cake!.name;
      _descriptionController.text = widget.cake!.description;
      _priceController.text = widget.cake!.price.toStringAsFixed(0);
      _networkImageUrl = widget.cake!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 1000);
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _pickedImageBytes = imageBytes;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal memilih gambar: $e")));
    }
  }

  Future<void> _saveCake() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    String? imageUrl;
    final user = supabase.auth.currentUser;
    try {
      if (_imageFile != null) {
        final imageBytes = await _imageFile!.readAsBytes();
        final fileName =
            '${user!.id}_${DateTime.now().millisecondsSinceEpoch}.${_imageFile!.path.split('.').last}';
        await supabase.storage
            .from('cakeimage')
            .uploadBinary(fileName, imageBytes);
        imageUrl = supabase.storage.from('cakeimage').getPublicUrl(fileName);
      } else {
        imageUrl = _networkImageUrl;
      }
      final cakeData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'image_url': imageUrl
      };
      if (widget.cake != null) {
        await supabase.from('cakes').update(cakeData).eq('id', widget.cake!.id);
      } else {
        await supabase.from('cakes').insert(cakeData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Kue berhasil disimpan!'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } on StorageException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal upload gambar: ${e.message}'),
            backgroundColor: Colors.red));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal menyimpan kue: $e'),
            backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImageBytes != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(_pickedImageBytes!, fit: BoxFit.cover));
    }
    if (_networkImageUrl != null) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(_networkImageUrl!, fit: BoxFit.cover));
    }
    return const Center(
      child: Icon(Icons.image_outlined, size: 36, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cake == null ? 'Tambah Kue Baru' : 'Edit Kue'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kue',
                          prefixIcon: Icon(Icons.cake_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          prefixText: 'Rp ',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty ? 'Harga tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      // --- Area Pilih Gambar Dipindahkan ke Sini ---
                      InkWell(
                        onTap: _isLoading ? null : _pickImage,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Center(
                            child: _pickedImageBytes != null ||
                                    _networkImageUrl != null
                                ? _buildImagePreview()
                                : const Text('Pilih Gambar',
                                    style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCake,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        widget.cake == null ? 'Simpan Kue Baru' : 'Update Kue',
                        style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
