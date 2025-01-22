import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'category_form.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ApiService apiService = ApiService();

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await apiService.getCategories();
      if (response != null && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Data kosong atau tidak valid');
      }
    } catch (e) {
      throw Exception('Gagal memuat kategori: $e');
    }
  }

  void openCategoryForm({Map<String, dynamic>? category}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryForm(
          category: category,
          onSave: () => setState(() {}), // Refresh data setelah simpan
        ),
      ),
    );
  }

  Future<void> handleDeleteCategory(int id) async {
    try {
      final response = await apiService.deleteCategory(id);
      if (response != null && response['message'] == 'Kategori berhasil dihapus') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori berhasil dihapus')),
        );
        setState(() {});
      } else {
        throw Exception(response?['error'] ?? 'Gagal menghapus kategori');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus kategori ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await handleDeleteCategory(id); // Hapus kategori
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 30),
            onPressed: () => openCategoryForm(),
          ),
        ],
        // AppBar dengan Gradasi Biru dan Ungu
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
      body: FutureBuilder<List<dynamic>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tidak ada kategori tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          } else {
            final categories = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        category['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        category['description'],
                        style: TextStyle(fontSize: 14),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          category['image_file'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, size: 40);
                          },
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => openCategoryForm(category: category),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDeleteConfirmationDialog(category['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
