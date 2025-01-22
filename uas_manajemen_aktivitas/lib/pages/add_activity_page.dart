import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/api_service.dart';
import '../utils/shared_prefs_helper.dart';

class AddActivityPage extends StatefulWidget {
  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String? selectedCategory;
  String date = '';
  List<dynamic> categories = [];
  final TextEditingController dateController = TextEditingController();
  bool isLoading = false; // Indikator loading untuk tombol tambah aktivitas

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await apiService.getData('kategori/get_categories.php');
      setState(() {
        categories = data['data'] ?? [];
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $error')),
      );
    }
  }

  Future<void> addActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true; // Set loading state
      });

      try {
        // Get user_id from Shared Preferences
        final userId = await SharedPrefsHelper.getUserId();

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: User ID tidak ditemukan. Login ulang.')),
          );
          setState(() {
            isLoading = false; // Matikan loading state
          });
          return;
        }

        // Kirim data ke API
        final response = await apiService.postData('aktivitas/add_activities.php', {
          'name': name,
          'description': description,
          'category_id': selectedCategory,
          'date': date,
          'user_id': userId, // Tambahkan user_id dari Shared Preferences
        });

        // Log response untuk debugging
        print('Response dari API: $response');

        // Validasi respon dari API
        if (response != null && response['status'] == 'success' && response['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );

          // Berhasil ditambahkan, kembali ke halaman sebelumnya
          Navigator.pop(
            context,
            Activity(
              name: name,
              description: description,
              categoryId: selectedCategory,
              date: date,
              isCompleted: false, // Status default belum selesai
            ),
          );
        } else if (response != null && response['error'] != null) {
          // Tampilkan error dari API jika ada
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan aktivitas: ${response['error']}')),
          );
        } else {
          // Fallback untuk respons tak terduga
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan tak terduga saat menambahkan aktivitas.')),
          );
        }
      } catch (error) {
        // Tangani error dari API atau jaringan
        print('Error saat menambahkan aktivitas: $error'); // Log error untuk debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding activity: $error')),
        );
      } finally {
        setState(() {
          isLoading = false; // Matikan loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Aktivitas'),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Aktivitas Input
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nama Aktivitas',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama aktivitas wajib diisi';
                      }
                      return null;
                    },
                    onSaved: (value) => name = value!,
                  ),
                ),
                // Deskripsi Input
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi wajib diisi';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value!,
                  ),
                ),
                // Kategori Dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    value: selectedCategory,
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Row(
                          children: [
                            if (category['image_url'] != null)
                              Image.network(
                                category['image_url'],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            SizedBox(width: 8),
                            Text(category['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori wajib dipilih';
                      }
                      return null;
                    },
                  ),
                ),
                // Tanggal Aktivitas
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal (YYYY-MM-DD)',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          date = DateFormat('yyyy-MM-dd').format(pickedDate);
                          dateController.text = date;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal wajib diisi';
                      }
                      return null;
                    },
                    onSaved: (value) => date = value!,
                  ),
                ),
                // Tombol Tambah Aktivitas
                ElevatedButton(
                  onPressed: isLoading ? null : addActivity, // Nonaktifkan tombol saat loading
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white) // Tampilkan indikator loading
                      : Text('Tambah Aktivitas'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
