import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_manajemen_aktivitas/pages/register_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true ? HomePage() : LoginPage();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage()
      },
    );
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userName'); // Periksa jika sesi login ada
  }
}
