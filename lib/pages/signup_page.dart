
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../services/storage_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  Future<void> _signup(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    @override
    void initState() async{
      super.initState();
      //if storage['token'] is not null, navigate to home page
      final tmp = await storage.read(key: "token");
      if(tmp != ""){
        Navigator.pushNamed(context, '/home');
      }
    }
    final response = await http.post(
      Uri.parse('https://flashcard-backend-85by.onrender.com/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // If the server returns a 200 OK response, parse the JSON.

      final Map<String, dynamic> data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('Signup successful ')),
      );

      Navigator.pushNamed(context, '/');

    } else {
      // If the server did not return a 200 OK response, throw an exception.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyTextField(
              controller: _emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            SizedBox(height: 20),
            MyTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            MyButton(
              onTap: () {
              _signup(context);
            },
              text: 'Signup',
            ),
          ],
        ),
      ),
    );
  }
}
