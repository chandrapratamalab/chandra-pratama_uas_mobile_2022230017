import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/shared_prefs_helper.dart';
import '../widgets/custom_alert_dialog.dart';
import '../pages/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();

  bool isLoading = false;

  Future<void> loginUser() async {
    // Validasi input
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      CustomAlertDialog.show(
        context,
        title: 'Error',
        message: 'Username dan password tidak boleh kosong.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Panggil API login
      final response = await apiService.postData('auth/login.php', {
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      });

      print('Response dari API: $response');

      if (response['status'] == 'success') {
        final userName = response['data']['name'];
        final userId = response['data']['user_id'];

        // Simpan data pengguna ke SharedPrefsHelper
        await SharedPrefsHelper.saveUserId(userId.toString());
        await SharedPrefsHelper.saveUserName(userName);

        print('Nama pengguna yang disimpan: $userName');
        print('User ID yang disimpan: $userId');

        // Tampilkan dialog sukses login
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Login Berhasil'),
              content: Text('Selamat datang, $userName!'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Tutup dialog dan navigasi ke halaman utama
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        CustomAlertDialog.show(
          context,
          title: 'Login Gagal',
          message: response['message'],
        );
      }
    } catch (e) {
      print('Error saat login: $e');
      CustomAlertDialog.show(
        context,
        title: 'Error',
        message: 'Gagal terhubung ke server. Periksa koneksi Anda.',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,  // Menghilangkan ikon kembali
        backgroundColor: Colors.blueAccent,  // Warna latar belakang app bar
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Judul aplikasi
                Text(
                  'Aplikasi Manajemen Aktivitas',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 4),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Logo atau header
                Icon(Icons.login, size: 100, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Login ke Akun Anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                // Form login
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: loginUser,
                          child: Text('Login', style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48), backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Belum punya akun? Daftar',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
