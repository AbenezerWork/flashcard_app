import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class Flashcard extends StatefulWidget {
  final String question;
  final String answer;
  final String category;
  final String id;
  final VoidCallback onDelete;

  const Flashcard({super.key, required this.question, required this.answer, required this.category, required this.id, required this.onDelete});

  @override
  _FlashcardState createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  bool _isAnswerVisible = false;

  void _toggleAnswerVisibility() {
    setState(() {
      _isAnswerVisible = !_isAnswerVisible;
    });
  }

  Future<void> _deleteFlashcard() async {
    final token = await storage.read(key: "token");

    final response = await http.delete(
      Uri.parse('https://flashcard-backend-85by.onrender.com/api/v1/flashcards/${widget.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flashcard deleted successfully')),
      );
      widget.onDelete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete flashcard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleAnswerVisibility,
      child: Card(
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
                    widget.category,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _deleteFlashcard,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                widget.question,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (_isAnswerVisible)
                Text(
                  widget.answer,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
