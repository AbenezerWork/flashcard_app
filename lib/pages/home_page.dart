import 'package:flashcard_app/components/flashcard.dart';
import 'package:flashcard_app/components/my_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/storage_service.dart';
import '../components/my_deck.dart';
import 'deck_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _decks = [];
  Map<String,Flashcard> flashcards={};

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

  @override
  Widget build(BuildContext context) {
    print(_decks.isEmpty);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchDecks,
          ),
        ],
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
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await storage.delete(key: "token");
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: _decks.isEmpty
          ? Center(child: PrettyTextWidget(text:"You don't have any decks yet. Click the + button to add a deck."))
          : ListView.builder(
              itemCount: _decks.length,
              itemBuilder: (context, index) {
                final deck = _decks[index];
                final flashcards = List<Flashcard>.from(deck['Flashcards'].map((flashcard) => Flashcard(
                  question: flashcard['question'],
                  id: flashcard['ID'].toString(),
                  answer: flashcard['answer'],
                  category: flashcard['category'],
                  onDelete: () => _fetchDecks(),
                )));

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeckPage(
                          title: deck['name'],
                          flashcards: flashcards,
                          id: deck['ID'].toString(),
                          onRefresh: _fetchDecks,
                        ),
                      ),
                    );
                  },
                  child: Deck(
                    title: deck['name'],
                    flashcards: flashcards,
                    id: deck['ID'].toString(),
                    onDelete: _fetchDecks,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-deck');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
