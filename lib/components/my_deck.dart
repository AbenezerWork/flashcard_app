import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import 'flashcard.dart';

class Deck extends StatelessWidget {
  final String title;
  final String id;
  final List<Flashcard> flashcards;
  final VoidCallback onDelete;

  const Deck({super.key, required this.title, required this.flashcards, required this.id, required this.onDelete});

  Future<void> _deleteDeck() async {
    final token = await storage.read(key: "token");

    final response = await http.delete(
      Uri.parse('https://flashcard-backend-85by.onrender.com/api/v1/decks/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      onDelete();
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteDeck,
                ),
              ],
            ),
            SizedBox(height: 10),
            ...flashcards.take(3).map((flashcard) => Text(flashcard.question)),
          ],
        ),
      ),
    );
  }
}
