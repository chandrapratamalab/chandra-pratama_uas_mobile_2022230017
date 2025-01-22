import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // Import ApiService

class Activity {
  final int id;
  final String name;
  final String description;
  final String date;
  final bool isCompleted;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'] ?? 'No name',
      description: json['description'] ?? 'No description',
      date: json['date'] ?? 'No date',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'isCompleted': isCompleted,
    };
  }
}

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<Activity> activities = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User ID tidak ditemukan. Login ulang.')),
        );
        return;
      }

      final url = 'http://teknologi22.xyz/project_api/api_chandra/aktivitas/get_activities.php?user_id=$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        if (responseBody.contains('{')) {
          responseBody = responseBody.substring(responseBody.indexOf('{'));
        }

        final data = jsonDecode(responseBody);
        if (data.containsKey('data') && data['data'] is List) {
          List<dynamic> activityData = data['data'];

          setState(() {
            activities = activityData.map((activity) => Activity.fromJson(activity)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: Struktur data tidak valid.')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Gagal memuat data aktivitas dari API')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching activities: $error')),
      );
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      final result = await apiService.deleteActivity(id);

      if (result.containsKey("message")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"])),
        );

        setState(() {
          activities.removeWhere((activity) => activity.id == id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["error"] ?? "Gagal menghapus aktivitas.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting activity: $error')),
      );
    }
  }

  Future<void> showCompleteDialog(int activityId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selesaikan Aktivitas?'),
          content: Text('Apakah Anda yakin ingin menyelesaikan aktivitas ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Selesaikan'),
              onPressed: () async {
                await deleteActivity(activityId);
                Navigator.of(context).pop();
              },
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
        title: Text('Daftar Aktivitas Anda'),
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
        ), // AppBar gradient
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : activities.isEmpty
          ? Center(child: Text('Tidak ada aktivitas.'))
          : ListView.builder(
        padding: EdgeInsets.all(8), // Tambahkan padding di sekitar list
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8), // Margin antar card
            elevation: 6, // Memberikan bayangan pada card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Membuat sudut card lebih melengkung
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16), // Padding di dalam card
              title: Text(
                activity.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent, // Mengubah warna teks judul
                ),
              ),
              subtitle: Text(
                activity.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.purple, // Ubah warna ikon
                  size: 30,
                ),
                onPressed: () {
                  showCompleteDialog(activity.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
