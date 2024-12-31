import 'package:flashcard_app/components/flashcard.dart';
import 'package:flashcard_app/pages/add_flashcard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/storage_service.dart';
import '../components/my_text.dart';

class DeckPage extends StatefulWidget {
  final String title;
  final List<Flashcard> flashcards;
  final String id;
  final VoidCallback onRefresh;

  const DeckPage({super.key, required this.title, required this.flashcards, required this.id, required this.onRefresh});

  @override
  _DeckPageState createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  List<dynamic> _decks = [];

  @override
  void initState() {
    super.initState();
    _fetchDecks();
  }

  Future<void> _fetchDecks() async {
    final token = await storage.read(key: "token");
    final response = await http.get(
      Uri.parse('https://flashcard-backend-85by.onrender.com/api/v1/decks'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _decks = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load decks')),
      );
    }
  }

  void _refreshFlashcards() {
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await storage.delete(key: "token");
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Decks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._decks.map((deck) {
              return ListTile(
                title: Text(deck['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeckPage(
                        title: deck['name'],
                        flashcards: List<Flashcard>.from(deck['Flashcards'].map((flashcard) => Flashcard(
                          question: flashcard['question'],
                          id: flashcard['ID'].toString(),
                          answer: flashcard['answer'],
                          category: flashcard['category'],
                          onDelete: () => _fetchDecks(),
                        ))),
                        id: deck['ID'].toString(),
                        onRefresh: _fetchDecks,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: widget.flashcards.isEmpty
          ? Center(child: PrettyTextWidget(text: "You don't have any flashcards yet. Click the + button to add a flashcard."))
          : PageView.builder(
              itemCount: widget.flashcards.length,
              itemBuilder: (context, index) {
                return Flashcard(
                  question: widget.flashcards[index].question,
                  answer: widget.flashcards[index].answer,
                  category: widget.flashcards[index].category,
                  id: widget.flashcards[index].id,
                  onDelete: _refreshFlashcards,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFlashcardPage(deckId: widget.id),
            ),
          );
          widget.onRefresh();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
