import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final controllerPass = TextEditingController();
  final controllerConfirmPassword = TextEditingController();
  final controllerQuestion = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool validate = true;

  bool isValidPass() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$')
        .hasMatch(controllerPass.text);
  }

  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(emailController.text);
  }

  void alerta(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  void register() async {
    var registerBody = {
      "email": emailController.text,
      "pass": controllerPass.text,
      "question": controllerQuestion.text,
      "usertype": "User"
    };

    var response = await http.post(
        Uri.parse("https://192.168.1.100:8443/api/cadastro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(registerBody));

    if (response.statusCode == 201) {

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário criado com sucesso!")));
      Navigator.pop(context);
    }
    if (response.statusCode == 302) {
      alerta(context, "Erro ao cadastrar usuário", "Erro ao cadastrar usuário");
    }
  }

  bool obscurePass = true;

  @override
  void initState() {
    super.initState();
    obscurePass = true;

    _init();
  }

  _init() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Usuário"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 40,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Text(
                      "Formulário de Cadastro:",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(1, 1, 1, 0.7),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  // validação de input
                  validator: (String? valor) {
                    if (valor != null && valor.isEmpty ||
                        isValidEmail() == false) {
                      return 'Campo de email não pode ser nulo ou não válido, tenha mais de 8 caracteres entre símbolos, letras e números';
                    }
                    if (valor!.length < 7) {
                      return 'O email não pode ter menos de 7 caracteres';
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
                    if (valor!.isEmpty || valor.length < 10) {
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
                  validator: (String? valor) {
                    if (valor != null && valor.isEmpty ||
                        isValidPass() == false) {
                      return 'Campo senha não pode ser vazio ou inválido!';
                    }
                    return null;
                  },
                  controller: controllerPass,
                  obscureText: obscurePass,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter a password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePass = !obscurePass;
                            });
                          },
                          icon: obscurePass
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: TextFormField(
                  validator: (String? valor) {
                    if (valor != null && valor.isEmpty ||
                        isValidPass() == false) {
                      return 'Campo senha não pode ser vazio ou inválido!';
                    }
                    if (controllerConfirmPassword.text != controllerPass.text) {
                      return "As senhas são diferentes!";
                    }
                    return null;
                  },
                  controller: controllerConfirmPassword,
                  obscureText: obscurePass,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    // prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                        icon: obscurePass
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  height: 40,
                  width: 130,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5)),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        register();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Erro ao cadastrar usuário!")));
                      }
                    },
                    child: const Text(
                      'Cadastrar',
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
