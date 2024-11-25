import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(ChatGPTClone());

class ChatGPTClone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Clone',
      theme: ThemeData.dark(),
      home: ChatHomePage(),
    );
  }
}

class ChatHomePage extends StatefulWidget {
  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  List<Conversation> conversations = [];
  Conversation? selectedConversation;
  TextEditingController messageController = TextEditingController();
  FocusNode messageFocusNode = FocusNode(); // Hinzugefügt

  // Beispiel-Fragen
  final List<String> exampleQuestions = [
    'Erkläre Quantenphysik in einfachen Worten.',
    'Wie funktioniert maschinelles Lernen?',
    'Was sind die neuesten Trends in der Technologie?',
  ];

  // Verwendetes Modell
  final String modelUsed = 'GPT-4';

  // Variable für Tipp-Indikator
  bool isBotTyping = false;

  // Set zur Verwaltung der ausgewählten Gespräche
  Set<Conversation> selectedConversations = {};

  @override
  void initState() {
    super.initState();
    // Entfernt, um kein neues Gespräch automatisch zu erstellen
    //_createNewConversation();
  }

  @override
  void dispose() {
    messageController.dispose();
    messageFocusNode.dispose(); // Fokus-Node entsorgen
    super.dispose();
  }

  void _createNewConversation() {
    setState(() {
      selectedConversation = Conversation(title: 'Neues Gespräch');
      conversations.add(selectedConversation!);
    });
  }

  void _deleteConversations(Set<Conversation> toDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bestätigen'),
          content: Text(
              'Möchten Sie die ausgewählten ${toDelete.length} Gespräche wirklich löschen?'),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Löschen'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  conversations
                      .removeWhere((convo) => toDelete.contains(convo));
                  selectedConversations.clear();
                  if (toDelete.contains(selectedConversation)) {
                    selectedConversation =
                        conversations.isNotEmpty ? conversations.last : null;
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _selectConversation(Conversation convo) {
    setState(() {
      selectedConversation = convo;
    });
  }

  void _renameConversation(Conversation convo) async {
    String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController titleController =
            TextEditingController(text: convo.title);
        return AlertDialog(
          title: Text('Gespräch umbenennen'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Neuer Titel',
            ),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () => Navigator.of(context).pop(titleController.text),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.trim().isNotEmpty) {
      setState(() {
        convo.title = newTitle.trim();
      });
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      // Wenn kein Gespräch ausgewählt ist, erstelle ein neues
      if (selectedConversation == null) {
        _createNewConversation();
      }

      setState(() {
        selectedConversation!.messages.add(Message(sender: 'User', text: text));
        isBotTyping = true; // Bot beginnt zu "tippen"
      });
      messageController.clear();

      // Automatisches Fokussieren nach dem Senden der Nachricht
      Future.delayed(Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(messageFocusNode);
      });

      // Simuliert eine Verzögerung, bevor die Bot-Antwort angezeigt wird
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          // Hier könnte die Chatbot-Antwort hinzugefügt werden
          selectedConversation!.messages
              .add(Message(sender: 'Bot', text: 'Antwort auf "$text"'));
          isBotTyping = false; // Bot hat aufgehört zu "tippen"
        });

        // Automatisches Fokussieren nach der Bot-Antwort
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(messageFocusNode);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar mit Logo und Lösch-Button
      appBar: AppBar(
        title: Row(
          children: [
            // Logo hinzufügen (auskommentiert)
            //Image.asset(
            // 'assets/logo.png',
            // height: 40,
            //),
            SizedBox(width: 10),
            Text('ChatGPT Clone'),
          ],
        ),
        actions: selectedConversations.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: 'Ausgewählte Gespräche löschen',
                  onPressed: () => _deleteConversations(selectedConversations),
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Seitliches Menü für Gespräche
              Container(
                width: 250,
                color: Colors.grey[900],
                child: Column(
                  children: [
                    // Button für neues Gespräch
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Neues Gespräch'),
                      onTap: () => _createNewConversation(),
                    ),
                    Divider(),
                    // Liste der Gespräche
                    Expanded(
                      child: ListView(
                        children: conversations.map((convo) {
                          bool isSelected =
                              selectedConversations.contains(convo);
                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedConversations.add(convo);
                                  } else {
                                    selectedConversations.remove(convo);
                                  }
                                });
                              },
                            ),
                            title: Text(convo.title),
                            selected: selectedConversation == convo,
                            onTap: () => _selectConversation(convo),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _renameConversation(convo),
                                  tooltip: 'Gespräch umbenennen',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Einzelnes Gespräch löschen mit Bestätigung
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Bestätigen'),
                                          content: Text(
                                              'Möchten Sie das Gespräch "${convo.title}" wirklich löschen?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Abbrechen'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: Text('Löschen'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  conversations.remove(convo);
                                                  selectedConversations
                                                      .remove(convo);
                                                  if (selectedConversation ==
                                                      convo) {
                                                    selectedConversation =
                                                        conversations.isNotEmpty
                                                            ? conversations.last
                                                            : null;
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  tooltip: 'Gespräch löschen',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Haupt-Chatbereich
              Expanded(
                child: Column(
                  children: [
                    // Chat-Nachrichten oder Beispiel-Fragen
                    Expanded(
                      child: selectedConversation != null &&
                              selectedConversation!.messages.isNotEmpty
                          ? ListView(
                              padding: EdgeInsets.all(16),
                              children: [
                                ...selectedConversation!.messages.map((msg) {
                                  return Align(
                                    alignment: msg.sender == 'User'
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: msg.sender == 'User'
                                            ? Colors.blueAccent
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(msg.text),
                                    ),
                                  );
                                }).toList(),
                                if (isBotTyping)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : _buildWelcomeScreen(),
                    ),
                    // Eingabefeld für Nachrichten
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.grey[800],
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              focusNode:
                                  messageFocusNode, // FocusNode hinzufügen
                              onSubmitted: _sendMessage,
                              decoration: InputDecoration(
                                hintText: 'Nachricht eingeben',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () =>
                                _sendMessage(messageController.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Delete-Button unten links
          if (selectedConversations.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton(
                onPressed: () => _deleteConversations(selectedConversations),
                backgroundColor: Colors.redAccent,
                tooltip: 'Ausgewählte Gespräche löschen',
                child: Icon(Icons.delete),
              ),
            ),
        ],
      ),
      // Optional: FloatingActionButton unten links statt Positioned
      /*
      floatingActionButton: selectedConversations.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _deleteConversations(selectedConversations),
              backgroundColor: Colors.redAccent,
              tooltip: 'Ausgewählte Gespräche löschen',
              child: Icon(Icons.delete),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      */
    );
  }

  // Widget für den Willkommensbildschirm mit Beispiel-Fragen
  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Willkommen bei ChatGPT Clone',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Hier sind einige Beispiele, was Sie fragen können:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Beispiel-Fragen auflisten
            ...exampleQuestions.map((question) {
              return GestureDetector(
                onTap: () {
                  // Wenn kein Gespräch ausgewählt ist, erstelle eines und sende die Frage
                  if (selectedConversation == null) {
                    _createNewConversation();
                  }
                  messageController.text = question;
                  _sendMessage(question);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.question_answer, color: Colors.white70),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 30),
            Text(
              'Verwendetes Modell: $modelUsed',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// Modell für ein Gespräch
class Conversation {
  String title;
  List<Message> messages;

  Conversation({required this.title}) : messages = [];
}

// Modell für eine Nachricht
class Message {
  String sender;
  String text;

  Message({required this.sender, required this.text});
}
