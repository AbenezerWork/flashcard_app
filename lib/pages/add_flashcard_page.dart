import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/storage_service.dart';

class AddFlashcardPage extends StatefulWidget {
  final String deckId;

  const AddFlashcardPage({super.key, required this.deckId});

  @override
  _AddFlashcardPageState createState() => _AddFlashcardPageState();
}

class _AddFlashcardPageState extends State<AddFlashcardPage> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _categoryController = TextEditingController();

  Future<void> _addFlashcard(BuildContext context) async {
    final question = _questionController.text;
    final answer = _answerController.text;
    final category = _categoryController.text;
    final token = await storage.read(key: "token");
    print(widget.deckId);

    final response = await http.post(
      Uri.parse('https://flashcard-backend-85by.onrender.com/api/v1/flashcards'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        //convert deckId to int
        'deckId': int.parse(widget.deckId),
        'question': question,
        'answer': answer,
        'category': category,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flashcard added successfully')),
      );
      Navigator.pop(context);
    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add flashcard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Question'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addFlashcard(context);
              },
              child: Text('Add Flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}
