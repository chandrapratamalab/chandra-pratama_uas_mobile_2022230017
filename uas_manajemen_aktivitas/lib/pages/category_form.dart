import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class CategoryForm extends StatefulWidget {
  final Map<String, dynamic>? category;
  final VoidCallback onSave;

  CategoryForm({this.category, required this.onSave});

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final ApiService apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      nameController.text = widget.category!['name'];
      descriptionController.text = widget.category!['description'];
    }
  }

  Future<void> saveCategory() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama kategori tidak boleh kosong')),
      );
      return;
    }

    try {
      if (widget.category == null) {
        // Tambah kategori
        await apiService.addCategory(
          nameController.text,
          descriptionController.text,
          selectedImage?.path ?? '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori berhasil ditambahkan')),
        );
      } else {
        // Edit kategori
        await apiService.updateCategory(
          widget.category!['id'],
          nameController.text,
          descriptionController.text,
          filePath: selectedImage?.path,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori berhasil diperbarui')),
        );
      }
      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan kategori: $e')),
      );
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Nama Kategori Input
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kategori',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            // Deskripsi Input
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            // Gambar Pilihan
            selectedImage == null && widget.category?['image'] != null
                ? Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Image.network(
                widget.category!['image'],
                height: 100,
                fit: BoxFit.cover,
              ),
            )
                : selectedImage != null
                ? Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Image.file(
                File(selectedImage!.path),
                height: 100,
                fit: BoxFit.cover,
              ),
            )
                : SizedBox(),
            // Pilih Gambar Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text('Pilih Gambar'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // Simpan Tombol
            ElevatedButton(
              onPressed: nameController.text.isEmpty ? null : saveCategory,
              child: Text(widget.category == null ? 'Tambah' : 'Update'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
