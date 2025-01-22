import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import '../utils/shared_prefs_helper.dart';

class SettingsPage extends StatelessWidget {
  final ApiService apiService = ApiService();

  // Fungsi logout
  Future<void> logoutUser(BuildContext context) async {
    try {
      // Menampilkan dialog konfirmasi logout
      final confirmLogout = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.white),
              ),
            ],
          );
        },
      );

      // Jika pengguna mengonfirmasi logout
      if (confirmLogout == true) {
        // Hapus semua data di SharedPreferences
        await SharedPrefsHelper.clearUserData();

        // Navigasi ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print('Error saat logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  // Fungsi update user
  Future<void> updateUserDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Profil'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    helperText: 'Kosongkan jika tidak ingin mengubah password.',
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Kirim hanya field yang diisi
                  await apiService.updateUser(
                    name: nameController.text.isNotEmpty ? nameController.text : null,
                    email: emailController.text.isNotEmpty ? emailController.text : null,
                    username: usernameController.text.isNotEmpty ? usernameController.text : null,
                    password: passwordController.text.isNotEmpty ? passwordController.text : null,
                  );

                  // Simpan nama yang diperbarui ke SharedPreferences
                  await SharedPrefsHelper.saveUserName(nameController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profil berhasil diperbarui.')),
                  );
                  Navigator.pop(context, true); // Mengirimkan hasil untuk memuat ulang HomePage
                } catch (e) {
                  print('Error saat memperbarui profil: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui profil: $e')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi delete user
  Future<void> deleteUser(BuildContext context) async {
    try {
      // Ambil user_id dari SharedPreferences
      final userId = await SharedPrefsHelper.getUserId();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }

      // Konfirmasi sebelum menghapus akun
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Konfirmasi Hapus Akun'),
            content: Text('Apakah Anda yakin ingin menghapus akun ini?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Hapus'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ],
          );
        },
      );

      // Jika pengguna mengonfirmasi penghapusan
      if (confirmDelete == true) {
        final result = await apiService.deleteUser();

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Akun berhasil dihapus.')),
          );

          // Hapus semua data di SharedPreferences
          await SharedPrefsHelper.clearUserData();

          // Navigasi ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          throw Exception(result['message'] ?? 'Gagal menghapus akun.');
        }
      }
    } catch (e) {
      print('Error saat menghapus akun: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus akun: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        backgroundColor: Colors.transparent,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => logoutUser(context),
              child: Text('Logout'),

              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blue[500], // Biru muda yang lebih lembut
                foregroundColor: Colors.white, // Warna teks putih
                elevation: 5, // Efek bayangan untuk kedalaman
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => updateUserDialog(context),
              child: Text('Update User'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.green[700], // Hijau muda yang lembut
                foregroundColor: Colors.white, // Warna teks putih
                elevation: 5, // Efek bayangan
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => deleteUser(context),
              child: Text('Hapus Akun'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.red[800], // Merah muda lembut
                foregroundColor: Colors.white, // Warna teks putih
                elevation: 5, // Efek bayangan
              ),
            ),
          ],
        ),
      ),
    );
  }
}
