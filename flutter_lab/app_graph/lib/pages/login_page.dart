import 'dart:convert';

import 'package:app_graph/pages/dashboard.dart';
import 'package:app_graph/pages/pass_recover_page.dart';
import 'package:app_graph/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _valor = false;

  late SharedPreferences preferences;

  var token;

  final controllerEmail = TextEditingController();
  final controllerSenha = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // inputs
  bool obscurePass = true;

  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(controllerEmail.text);
  }

  bool isValidPass() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$')
        .hasMatch(controllerSenha.text);
  }

  @override
  void initState() {
    super.initState();
    obscurePass = true;

    _init();
  }

  _init() async {
    preferences = await SharedPreferences.getInstance();

    controllerEmail.text = preferences.getString('email') ?? '';
    controllerSenha.text = preferences.getString('pass') ?? '';
    _valor = preferences.getBool('lembrar') ?? false;

    setState(() {});
  }

  login() async {
    var requestBody = {
      "email": controllerEmail.text,
      "pass": controllerSenha.text
    };

    var response = await http.post(
        Uri.parse("https://192.168.1.100:8443/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody));

    if (response.statusCode == 200) {
      var jsonFromApi = jsonDecode(response.body);

      if (jsonFromApi['message'] == "Autenticado") {
        var token = jsonFromApi['token'];
        preferences.setString('token', token);

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Dashboard(
            token: token,
          );
        }));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Usuário não cadastrado ou senha/email incorretos!")));
    }
  }

  Widget _buildLoginPage() {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 200, horizontal: 40),
          child: Column(
            children: [
              // email
              TextFormField(
                validator: (String? valor) {
                  if (valor != null && valor.isEmpty ||
                      isValidEmail() == false) {
                    return 'Campo de email não pode ser nulo ou não válido';
                  }
                  if (valor!.length < 7) {
                    return 'O email não pode ter menos de 7 caracteres';
                  }
                  return null;
                },
                controller: controllerEmail,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    label: Text("Email"),
                    prefixIcon: Icon(Icons.email)),
              ),
              // senha
              TextFormField(
                obscureText: obscurePass,
                validator: (String? valor) {
                  if (valor != null && valor.isEmpty ||
                      isValidPass() == false) {
                    return 'Campo senha não pode ser vazia ou inválida!';
                  }
                  return null;
                },
                controller: controllerSenha,
                decoration: InputDecoration(
                    hintText: "Enter password",
                    border: const UnderlineInputBorder(),
                    label: const Text("Senha"),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                        icon: obscurePass
                            ? const Icon(Icons.visibility_off)
                            : (const Icon(Icons.visibility)))),
              ),
              const SizedBox(
                height: 20,
              ),
              CheckboxListTile(
                  title: const Text(
                    "Lembrar usuário",
                    style: TextStyle(fontSize: 16),
                  ),
                  value: _valor,
                  onChanged: (value) {
                    setState(() {
                      _valor = !_valor;
                    });
                  }),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (_valor) {
                        preferences.setString("email", controllerEmail.text);
                        preferences.setString("pass", controllerSenha.text);
                        preferences.setBool("lembrar", _valor);
                      } else {
                        preferences.remove('email');
                        preferences.remove('pass');
                        preferences.remove('lembrar');
                      }
                      login();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro ao Logar!')));
                    }
                  },
                  child: const Text(
                    "Logar",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage()));
                    },
                    child: const Text(
                      "Cadastrar Novo Usuário",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PassRecoverPage()));
                    },
                    child: const Text("Recuperar Senha")),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login do Sistema",
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: _buildLoginPage(),
    );
  }
}
