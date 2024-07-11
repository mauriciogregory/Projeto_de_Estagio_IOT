//import 'package:app_graph/tela_login.dart';
import 'dart:io';

import 'package:app_graph/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(MyApp(token: preferences.getString("token")));
}

class MyApp extends StatelessWidget {
  final token;

  MyApp({
    @required this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.blue),
      home: const Splash(),
    );
  }
}

// certificado de validação
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) {
        final isValidHost =
            ["192.168.1.100"].contains(host); // <-- pemissão para o host
        return isValidHost;
      });
  }
}
