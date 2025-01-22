import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_manajemen_aktivitas/pages/settings_page.dart';

import 'activity_list_page.dart';
import 'activity_page.dart';
import 'add_activity_page.dart';
import 'category_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    // Ambil data pengguna dari SharedPreferences (jika ada)
    final prefs = await SharedPreferences.getInstance();
    final storedUserName = prefs.getString('user_name');
    setState(() {
      userName = storedUserName ?? 'Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Beranda',
          style: TextStyle(
            color: Colors.white, // Warna teks AppBar menjadi putih
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple], // Gradasi biru dan ungu
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan nama pengguna
          Container(
            width: double.infinity,
            color: Colors.blue[50],
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selamat datang, $userName!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ),

          // Card untuk aktivitas Anda (hanya menampilkan judul)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 6.0, // Menambahkan bayangan lebih halus
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // Sudut melengkung
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Text(
                  'Aktivitas Anda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900], // Menggunakan warna biru lebih gelap
                  ),
                ),
                subtitle: null, // Hanya menampilkan judul tanpa jumlah
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActivityPage()),
                  );
                },
              ),
            ),
          ),

          // Kategori Favorit
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Kategori Favorit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900], // Warna teks lebih gelap untuk kontras
              ),
            ),
          ),

          // Menampilkan kategori favorit dengan memenuhi ruang horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Menyebarkan kartu dengan jarak yang sama
              children: [
                CategoryCard(title: 'Olahraga', icon: Icons.sports_soccer),
                CategoryCard(title: 'Belajar', icon: Icons.school),
                CategoryCard(title: 'Karaoke', icon: Icons.music_note),
                CategoryCard(title: 'Hangout', icon: Icons.fastfood),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 198.5, bottom: 10.5),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Agar modal tidak dipenuhi seluruh layar
              builder: (context) => Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.list, color: Colors.purple), // Ikon menjadi ungu
                    title: Text('Daftar Aktivitas', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ActivityListPage()),
                      );
                    },
                  ),
                  Divider(), // Menambahkan pembatas antara pilihan
                  ListTile(
                    leading: Icon(Icons.add, color: Colors.purple), // Ikon menjadi ungu
                    title: Text('Tambah Aktivitas', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddActivityPage()),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          label: Text('Menu Aktivitas', style: TextStyle(color: Colors.white)), // Teks FAB menjadi putih
          icon: Icon(Icons.menu, color: Colors.white), // Ikon FAB menjadi putih
          backgroundColor: Colors.purple, // Warna tombol menggunakan ungu
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white), // Ikon warna putih
            label: 'Beranda',
            backgroundColor: Colors.purple, // Background ungu
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category, color: Colors.white), // Ikon warna putih
            label: 'Kategori',
            backgroundColor: Colors.purple, // Background ungu
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white), // Ikon warna putih
            label: 'Pengaturan',
            backgroundColor: Colors.purple, // Background ungu
          ),
        ],
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryPage()),
            );
          } else if (index == 2) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
            if (result == true) {
              await getUserData();
            }
          }
        },
        selectedItemColor: Colors.white, // Warna item yang dipilih menjadi putih
        unselectedItemColor: Colors.white70, // Warna item yang tidak dipilih menjadi sedikit transparan
        backgroundColor: Colors.purple, // Background bar menggunakan ungu
        type: BottomNavigationBarType.fixed, // Tipe fixed agar semua item terlihat jelas
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const CategoryCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      elevation: 6.0, // Menambahkan bayangan untuk tampilan lebih dalam
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Sudut melengkung
      ),
      child: InkWell(
        onTap: () {
          // Aksi saat kategori dipilih (misalnya navigasi ke halaman kategori)
        },
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50, // Membesarkan ikon untuk tampil lebih jelas
                color: Colors.blue[900], // Menggunakan warna biru untuk ikon
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
