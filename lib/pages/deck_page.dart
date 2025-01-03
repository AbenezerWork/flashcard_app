import 'package:flashcard_app/components/flashcard.dart';
import 'package:flashcard_app/pages/add_flashcard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
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
  bool _isPageView = true;
  List<Flashcard> _shuffledFlashcards = [];

  @override
  void initState() {
    super.initState();
    _fetchDecks();
    _shuffleFlashcards();
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

  void _shuffleFlashcards() {
    _shuffledFlashcards = List.from(widget.flashcards);
    _shuffledFlashcards.shuffle(Random());
  }

  void _refreshFlashcards() {
    widget.onRefresh();
  }

  void _toggleView() {
    setState(() {
      _isPageView = !_isPageView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isPageView ? Icons.view_list : Icons.view_carousel),
            onPressed: _toggleView,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
              ),
              child: Text(
                'Menu',
                style: TextStyle(
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
            }),
          ],
        ),
      ),
      body: _shuffledFlashcards.isEmpty
          ? Center(child: PrettyTextWidget(text: "You don't have any flashcards yet. Click the + button to add a flashcard."))
          : _isPageView
              ? PageView.builder(
                  itemCount: _shuffledFlashcards.length,
                  itemBuilder: (context, index) {
                    return Flashcard(
                      question: _shuffledFlashcards[index].question,
                      answer: _shuffledFlashcards[index].answer,
                      category: _shuffledFlashcards[index].category,
                      id: _shuffledFlashcards[index].id,
                      onDelete: _refreshFlashcards,
                    );
                  },
                )
              : ListView.builder(
                  itemCount: _shuffledFlashcards.length,
                  itemBuilder: (context, index) {
                    return Flashcard(
                      question: _shuffledFlashcards[index].question,
                      answer: _shuffledFlashcards[index].answer,
                      category: _shuffledFlashcards[index].category,
                      id: _shuffledFlashcards[index].id,
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
