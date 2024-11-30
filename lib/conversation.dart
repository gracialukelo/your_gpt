import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Clone',
      theme: ThemeData.light(), // Optional: Nutze ein helles Theme wie im Screenshot
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT 4.0', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: Colors.black),
          ),
        ],
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Zentrales Icon in der Mitte des Bildschirms
          Expanded(
            child: Center(
              child: Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
          ),
          // Buttons für Vorschläge am unteren Rand
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSuggestionButton("Erstelle eine Illustration", "für eine Bäckerei"),
                  _buildSuggestionButton(
                      "Schlag mir Aktivitäten vor", "um nach dem Umzug neu zu starten"),
                  _buildSuggestionButton("Erkläre mir Quantenphysik", "in einfachen Worten"),
                ],
              ),
            ),
          ),
          // Eingabefeld
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: _buildInputBar(),
          ),
        ],
      ),
    );
  }

  // Vorschläge-Button
  Widget _buildSuggestionButton(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () {
          // Hier wird die jeweilige Funktion ausgeführt
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Eingabefeld mit Icons
  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.grey),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Nachricht",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.language, color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
