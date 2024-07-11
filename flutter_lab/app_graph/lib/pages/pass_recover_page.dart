import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PassRecoverPage extends StatefulWidget {
  const PassRecoverPage({super.key});

  @override
  State<PassRecoverPage> createState() => _PassRecoverPageState();
}

class _PassRecoverPageState extends State<PassRecoverPage> {
  final formChaves = GlobalKey<FormState>();

  final passController = TextEditingController();
  final passConfirmController = TextEditingController();
  final controllerQuestion = TextEditingController();
  final emailController = TextEditingController();

  bool validate = true;

  bool obscuredPass = true;
  bool obscuredConfirm = true;

  bool isValidPass() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$')
        .hasMatch(passController.text);
  }

  void salvar() async {
    var body = {
      "email": emailController.text,
      "pass": passController.text,
      "question": controllerQuestion.text,
    };

    var response = await http.patch(
        Uri.parse("https://192.168.1.100:8443/api/recover"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha Resetada com Sucesso!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erro ")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Recuperar Senha"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formChaves,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 30.0, left: 15),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Preencha os campos abaixo:",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(1, 1, 1, 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  // validação de input
                  validator: (String? valor) {
                    if (valor != null && valor.isEmpty) {
                      return 'Campo de email não pode ser nulo!';
                    }

                    return null;
                  },
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Email'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: TextFormField(
                  validator: (String? valor) {
                    if (valor!.isEmpty) {
                      return "Campo não pode ser nulo e deve conter mais de 10 caracters";
                    }
                    return null;
                  },
                  controller: controllerQuestion,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.red),
                      border: OutlineInputBorder(),
                      labelText: 'Security Question',
                      hintText: 'Security Question'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: TextFormField(
                  controller: passController,
                  validator: (String? valor) {
                    if (valor!.isEmpty || isValidPass() == false) {
                      return "Não pode ser vazio e deve conter caracteres especiais, letras e números";
                    }
                    return null;
                  },
                  obscureText: obscuredPass,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Password',
                      hintText: 'Enter a strong password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscuredPass = !obscuredPass;
                            });
                          },
                          icon: obscuredPass
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: TextFormField(
                  controller: passConfirmController,
                  validator: (String? valor) {
                    if (passConfirmController.text != passController.text) {
                      return "As senha não conferem!";
                    } else if (valor!.isEmpty) {
                      return "O campo não pode ser nulo!";
                    }
                    return null;
                  },
                  obscureText: obscuredConfirm,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm New Password',
                      hintText: 'Enter a strong password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscuredConfirm = !obscuredConfirm;
                            });
                          },
                          icon: obscuredConfirm
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5)),
                  child: TextButton(
                    onPressed: () {
                      if (formChaves.currentState?.validate() == true) {
                        salvar();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Erro")));
                      }
                    },
                    child: const Text(
                      'Recuperar',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
