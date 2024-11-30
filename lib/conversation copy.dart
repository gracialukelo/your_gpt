import 'package:flutter/material.dart';
import 'dart:async'; // Für Timer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Clone',
      theme: ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode(); // Fokus für das Eingabefeld
  bool _isSidebarOpen = false;
  bool _isLoading = false;

  // Liste der Gespräche
  final List<Conversation> _conversations = [
    Conversation(title: "Neues Gespräch", messages: [])
  ];

  int _selectedConversationIndex = 0;

  // Aktives Gespräch
  Conversation get _currentConversation => _conversations[_selectedConversationIndex];

  // Nachricht senden
  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _currentConversation.messages.add(Message(sender: "user", text: message));
      _isLoading = true;
      _messageController.clear();
    });

    // Fokus im Eingabefeld behalten
    _messageFocusNode.requestFocus();

    // Simulierte Verzögerung für die Antwort
    await Future.delayed(const Duration(seconds: 1));

    // Hier kannst du später dein LLM integrieren
    String botResponse = "Das ist eine generierte Antwort auf: '$message'.";

    setState(() {
      _currentConversation.messages.add(Message(sender: "bot", text: botResponse));
      _isLoading = false;
    });
  }

  // Neues Gespräch starten
  void _startNewConversation() {
    setState(() {
      _conversations.add(
        Conversation(
          title: "Gespräch ${_conversations.length + 1}",
          messages: [],
        ),
      );
      _selectedConversationIndex = _conversations.length - 1;
      _isSidebarOpen = false;
    });
  }

  // Gespräch löschen
  void _deleteConversation(int index) async {
    bool confirm = await _showConfirmationDialog(
      title: "Gespräch löschen",
      content: "Möchtest du dieses Gespräch wirklich löschen?",
    );
    if (confirm) {
      setState(() {
        _conversations.removeAt(index);
        if (_conversations.isEmpty) {
          _conversations.add(Conversation(title: "Neues Gespräch", messages: []));
        }
        _selectedConversationIndex = 0;
      });
    }
  }

  // Alle Gespräche löschen
  void _deleteAllConversations() async {
    bool confirm = await _showConfirmationDialog(
      title: "Alle Gespräche löschen",
      content: "Möchtest du wirklich alle Gespräche löschen?",
    );
    if (confirm) {
      setState(() {
        _conversations.clear();
        _conversations.add(Conversation(title: "Neues Gespräch", messages: []));
        _selectedConversationIndex = 0;
      });
    }
  }

  // Gespräch umbenennen
  void _renameConversation(int index) async {
    String newName = _conversations[index].title;
    final TextEditingController _renameController =
        TextEditingController(text: newName);
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Gespräch umbenennen"),
          content: TextField(
            controller: _renameController,
            autofocus: true,
            textInputAction: TextInputAction.next, // Ermöglicht Tab-Navigation
            decoration: const InputDecoration(
              hintText: "Neuer Name",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Abbrechen"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Umbenennen"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);

    if (confirm) {
      setState(() {
        _conversations[index].title = _renameController.text.trim();
      });
    }
  }

  // Bestätigungsdialog anzeigen
  Future<bool> _showConfirmationDialog(
      {required String title, required String content}) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text("Abbrechen"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("Löschen"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // Sidebar
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white, // Anpassung an das Hauptfenster
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white, // Anpassung an das Hauptfenster
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Gespräche",
                  style: TextStyle(
                    color: Colors.black, // Anpassung der Textfarbe
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: _startNewConversation,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return ListTile(
                  selected: _selectedConversationIndex == index,
                  selectedTileColor: Colors.blue[100],
                  title: Text(
                    conversation.title,
                    style: TextStyle(
                      color: _selectedConversationIndex == index
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _renameConversation(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteConversation(index),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedConversationIndex = index;
                      _isSidebarOpen = false;
                    });
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text(
              "Alle löschen",
              style: TextStyle(color: Colors.red),
            ),
            onTap: _deleteAllConversations,
          ),
        ],
      ),
    );
  }

  // Eingabefeld
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
            onPressed: () {
              // Mikrofon-Funktion
            },
            icon: const Icon(Icons.mic, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              focusNode: _messageFocusNode, // Fokus dem Eingabefeld zuweisen
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Nachricht eingeben...",
                border: InputBorder.none,
              ),
              onSubmitted: (value) => _sendMessage(value),
            ),
          ),
          IconButton(
            onPressed: () => _sendMessage(_messageController.text),
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // Nachrichten anzeigen
  Widget _buildMessage(Message message) {
    final isUser = message.sender == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Hauptbildschirm
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (_isSidebarOpen) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    'ChatGPT 4.0',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: _toggleSidebar,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount:
                        _currentConversation.messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading &&
                          index == _currentConversation.messages.length) {
                        return _buildTypingIndicator(); // Angepasster Ladeindikator
                      }

                      final message = _currentConversation.messages[index];
                      return _buildMessage(message);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildInputBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar ein-/ausblenden
  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  // Tippanimation als Ladeindikator
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: TypingIndicator(),
      ),
    );
  }
}

// Nachrichtenmodell
class Message {
  final String sender;
  final String text;

  Message({required this.sender, required this.text});
}

// Gesprächsmodell
class Conversation {
  String title;
  List<Message> messages;

  Conversation({required this.title, required this.messages});
}

// Tippanimation
class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.linear);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dotColor = Colors.grey; // Farbe anpassen

    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animation!,
            builder: (context, child) {
              return Opacity(
                opacity: _calculateOpacity(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: dotColor,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  double _calculateOpacity(int dotIndex) {
    double t = (_controller!.value * 3 - dotIndex).clamp(0.0, 1.0);
    return t;
  }
}
