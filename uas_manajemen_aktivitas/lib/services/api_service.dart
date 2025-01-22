  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  import '../utils/shared_prefs_helper.dart';

  class ApiService {
    static const String baseUrl = 'https://teknologi22.xyz/project_api/api_chandra';

    // GET request
    Future<dynamic> getData(String endpoint) async {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.contains('{')) {
          responseBody = responseBody.substring(responseBody.indexOf('{'));
        }
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to load data');
      }
    }

    // POST request
    Future<dynamic> postData(String endpoint, Map<String, dynamic> body) async {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.contains('{')) {
          responseBody = responseBody.substring(responseBody.indexOf('{'));
        }
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to post data');
      }
    }

    // Login function
    Future<void> login(String username, String password) async {
      final response = await postData('auth/login.php', {
        'username': username,
        'password': password,
      });

      if (response['status'] == 'success') {
        final userId = response['data']['user_id'];
        await SharedPrefsHelper.saveUserId(userId);
      } else {
        throw Exception('Login gagal');
      }
    }

    // Register function
    Future<Map<String, dynamic>> register(String name, String username, String email, String password) async {
      final url = Uri.parse('$baseUrl/auth/register.php');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.contains('{')) {
          responseBody = responseBody.substring(responseBody.indexOf('{'));
        }
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to register user');
      }
    }

    // Tambahkan kategori dengan gambar
    Future<dynamic> addCategory(String name, String description, String filePath) async {
      var uri = Uri.parse('$baseUrl/kategori/add_categories.php');
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan field data kategori
      request.fields['name'] = name;
      request.fields['description'] = description;

      // Tambahkan file gambar jika ada
      if (filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', filePath));
      }

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          String responseBody = response.body.trim();
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }
          return jsonDecode(responseBody);
        } else {
          throw Exception('Failed to add category');
        }
      } catch (e) {
        throw Exception('Error adding category: $e');
      }
    }

    // Fungsi untuk mendapatkan daftar kategori
    Future<dynamic> getCategories() async {
      final url = Uri.parse('$baseUrl/kategori/get_categories.php');
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          String responseBody = response.body.trim();
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }
          return jsonDecode(responseBody);
        } else {
          throw Exception('Failed to fetch categories');
        }
      } catch (e) {
        throw Exception('Error fetching categories: $e');
      }
    }

    // Fungsi untuk menghapus kategori
    Future<Map<String, dynamic>?> deleteCategory(int id) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/kategori/delete_categories.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}),
        );

        print('Mengirim ID ke API: $id'); // Debug log
        print('Respons API Delete Category: ${response.statusCode} - ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          // Parse respons jika valid
          String responseBody = response.body.trim();
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }

          final jsonResponse = jsonDecode(responseBody);
          if (jsonResponse != null && jsonResponse is Map<String, dynamic>) {
            return jsonResponse;
          } else {
            throw Exception('Format respons API tidak valid');
          }
        } else {
          // Menangani error dengan status selain 200
          return {'error': 'Gagal menghapus kategori. Status: ${response.statusCode}'};
        }
      } catch (e) {
        // Menangani kesalahan
        print('Error saat menghapus kategori: $e');
        return {'error': 'Terjadi kesalahan: $e'};
      }
    }

    // Fungsi untuk mengupdate kategori
    Future<dynamic> updateCategory(int id, String name, String description, {String? filePath}) async {
      var uri = Uri.parse('$baseUrl/kategori/update_categories.php');
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan ID kategori yang akan diupdate
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['description'] = description;

      // Tambahkan file gambar jika ada
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', filePath));
      }

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          String responseBody = response.body.trim();
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }
          return jsonDecode(responseBody);
        } else {
          throw Exception('Failed to update category');
        }
      } catch (e) {
        throw Exception('Error updating category: $e');
      }
    }

    // Fungsi untuk mengupdate user
    Future<dynamic> updateUser({
      String? name,
      String? email,
      String? username,
      String? password,
    }) async {
      // Ambil user_id dari SharedPreferences
      final userId = await SharedPrefsHelper.getUserId();

      if (userId == null) {
        throw Exception('User ID tidak ditemukan. Silakan login ulang.');
      }

      // Bangun body JSON hanya dengan field yang tidak null
      final body = {
        'user_id': userId,
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (username != null && username.isNotEmpty) 'username': username,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      try {
        // Kirim request ke endpoint update_profile.php
        final response = await http.post(
          Uri.parse('$baseUrl/update_profile.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          String responseBody = response.body.trim();
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }
          final decodedResponse = jsonDecode(responseBody);

          if (decodedResponse['success'] == true) {
            return decodedResponse; // Berikan respons sukses
          } else {
            throw Exception(decodedResponse['message'] ?? 'Gagal memperbarui pengguna.');
          }
        } else {
          throw Exception('Gagal memperbarui pengguna. Kode status: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error saat memperbarui pengguna: $e');
      }
    }




    // Fungsi untuk menghapus user
    Future<Map<String, dynamic>> deleteUser() async {
      // Ambil user_id dari SharedPreferences
      final userId = await SharedPrefsHelper.getUserId();

      if (userId == null) {
        throw Exception('User ID tidak ditemukan. Silakan login ulang.');
      }

      try {
        // Kirim permintaan ke server
        final response = await http.post(
          Uri.parse('$baseUrl/delete_user.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        );

        if (response.statusCode == 200) {
          // Bersihkan respons dari karakter tambahan
          String responseBody = response.body.trim();
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }

          return jsonDecode(responseBody);
        } else {
          throw Exception('Gagal menghapus akun. Kode status: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error saat menghapus akun: $e');
      }
    }

    Future<List<dynamic>> fetchActivities() async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan.');
      }

      final response = await http.get(Uri.parse('$baseUrl/aktivitas/get_activities.php?user_id=$userId'));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.contains('{')) {
          responseBody = responseBody.substring(responseBody.indexOf('{'));
        }

        final data = jsonDecode(responseBody);

        if (data.containsKey('data') && data['data'] is List) {
          return data['data'];
        } else {
          throw Exception('Struktur data tidak valid.');
        }
      } else {
        throw Exception('Gagal memuat data aktivitas dari API.');
      }
    }

    // Fungsi untuk menghapus aktivitas berdasarkan ID
    Future<Map<String, dynamic>> deleteActivity(int id) async {
      final url = Uri.parse("${baseUrl}/aktivitas/delete_activities.php");

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"id": id}),
        );

        if (response.statusCode == 200) {
          // Bersihkan respons dari karakter tambahan
          String responseBody = response.body.trim();

          // Jika respons mengandung '{', ambil bagian JSON dari sana
          if (responseBody.contains('{')) {
            responseBody = responseBody.substring(responseBody.indexOf('{'));
          }

          return jsonDecode(responseBody);
        } else {
          throw Exception('Gagal menghapus aktivitas. Kode status: ${response.statusCode}');
        }
      } catch (error) {
        throw Exception("Error deleting activity: $error");
      }
    }


  }
