import 'dart:async';

import 'package:app_graph/core/images.dart';
import 'package:app_graph/pages/login_page.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  //splash
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(71, 42, 96, 243)),

        child: Center(
          child: Image.asset(
            AppImages.logo,
            height: 150,
            width: 150,
          ),
        ),
      ),
    );
  }
}
