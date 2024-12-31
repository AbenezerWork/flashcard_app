import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/storage_service.dart';

class AddDeckPage extends StatefulWidget {
  const AddDeckPage({super.key});

  @override
  _AddDeckPageState createState() => _AddDeckPageState();
}

class _AddDeckPageState extends State<AddDeckPage> {
  final _nameController = TextEditingController();

  Future<void> _addDeck(BuildContext context) async {
    final name = _nameController.text;
    final token = await storage.read(key: "token");

    final response = await http.post(
      Uri.parse('https://flashcard-backend-85by.onrender.com/api/v1/decks'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'name': name,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck added successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add deck')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Deck Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addDeck(context);
              },
              child: Text('Add Deck'),
            ),
          ],
        ),
      ),
    );
  }
}
