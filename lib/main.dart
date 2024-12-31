import 'package:flashcard_app/pages/login_page.dart';
import 'package:flashcard_app/pages/home_page.dart';
import 'package:flashcard_app/pages/add_deck_page.dart';
import 'package:flashcard_app/pages/deck_page.dart';
import 'package:flashcard_app/pages/add_flashcard_page.dart';
import 'package:flashcard_app/pages/signup_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/add-deck': (context) => AddDeckPage(),
        '/deck': (context) => DeckPage(title: '', flashcards: [], id: "0", onRefresh: () {}),
        '/add-flashcard': (context) => AddFlashcardPage(deckId: "0"),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
