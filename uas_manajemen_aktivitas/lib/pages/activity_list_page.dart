import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/shared_prefs_helper.dart'; // Import SharedPrefsHelper untuk mengambil user_id

class ActivityListPage extends StatefulWidget {
  @override
  _ActivityListPageState createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  List<dynamic> activities = []; // List aktivitas
  List<dynamic> categories = []; // List kategori
  final ApiService apiService = ApiService();
  bool isLoading = true; // Indikator loading

  @override
  void initState() {
    super.initState();
    fetchActivities();
    fetchCategories(); // Ambil data kategori saat halaman dimuat
  }

  // Fungsi untuk mengambil daftar aktivitas
  Future<void> fetchActivities() async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User ID tidak ditemukan. Login ulang.')),
        );
        return;
      }

      final data = await apiService.getData('aktivitas/get_activities.php?user_id=$userId');
      setState(() {
        activities = data['data']; // Update daftar aktivitas
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching activities: $error')),
      );
    }
  }

  // Fungsi untuk mengambil daftar kategori
  Future<void> fetchCategories() async {
    try {
      final data = await apiService.getCategories(); // Memanggil API getCategories()
      setState(() {
        categories = data['data']; // Update daftar kategori
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $error')),
      );
    }
  }

  // Fungsi untuk mengupdate aktivitas
  Future<void> updateActivity(int id, {String? name, String? description, String? date, int? categoryId}) async {
    final userId = await SharedPrefsHelper.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User ID tidak ditemukan. Login ulang.')),
      );
      return;
    }

    // Siapkan body hanya dengan parameter yang tidak null
    final body = <String, String>{
      'id': id.toString(),
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (date != null) 'date': date,
    };

    try {
      final response = await apiService.postData('aktivitas/update_activities.php', body);
      if (response['message'] == 'Aktivitas berhasil diperbarui.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aktivitas berhasil diperbarui.')),
        );
        fetchActivities(); // Reload daftar aktivitas setelah update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui aktivitas: ${response['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating activity: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Aktivitas'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple], // Gradasi biru dan ungu
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ), // AppBar gradient
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Tampilkan loading jika isLoading true
          : activities.isEmpty
          ? Center(child: Text('Tidak ada aktivitas yang ditemukan.'))
          : ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0), // Sudut melengkung pada container
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.0,
                  offset: Offset(0, 2), // Shadow position
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                activity['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blueAccent, // Warna judul lebih cerah
                ),
              ),
              subtitle: Text(
                activity['description'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity['date'],
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.purple, // Ubah warna ikon menjadi ungu
                    onPressed: () {
                      // Tampilkan dialog untuk mengedit aktivitas
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final TextEditingController nameController =
                          TextEditingController(text: activity['name']);
                          final TextEditingController descriptionController =
                          TextEditingController(text: activity['description']);
                          final TextEditingController dateController =
                          TextEditingController(text: activity['date']);
                          int? selectedCategoryId = activity['category_id'];

                          return AlertDialog(
                            title: Text('Edit Aktivitas'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(labelText: 'Nama Aktivitas'),
                                  ),
                                  TextField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(labelText: 'Deskripsi'),
                                  ),
                                  TextField(
                                    controller: dateController,
                                    readOnly: true, // Jangan izinkan input manual
                                    decoration: InputDecoration(labelText: 'Tanggal'),
                                    onTap: () async {
                                      DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (pickedDate != null) {
                                        String formattedDate =
                                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                        dateController.text = formattedDate;
                                      }
                                    },
                                  ),
                                  DropdownButton<int>(
                                    value: selectedCategoryId,
                                    hint: Text('Pilih Kategori'),
                                    items: categories.map<DropdownMenuItem<int>>((category) {
                                      return DropdownMenuItem<int>(
                                        value: category['id'],
                                        child: Text(category['name']),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedCategoryId = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  updateActivity(
                                    activity['id'],
                                    name: nameController.text.isNotEmpty
                                        ? nameController.text
                                        : null,
                                    description: descriptionController.text.isNotEmpty
                                        ? descriptionController.text
                                        : null,
                                    date: dateController.text.isNotEmpty
                                        ? dateController.text
                                        : null,
                                    categoryId: selectedCategoryId != activity['category_id']
                                        ? selectedCategoryId
                                        : null,
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text('Simpan'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Batal'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
