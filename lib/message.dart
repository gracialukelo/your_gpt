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
      theme: ThemeData.dark(),
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
  List<Conversation> conversations = [];
  Conversation? selectedConversation;
  TextEditingController messageController = TextEditingController();
  TextEditingController conversationTitleController = TextEditingController();
  FocusNode messageFocusNode = FocusNode();
  bool isBotTyping = false;

  // Beispiel-Fragen
  final List<String> exampleQuestions = [
    'Erkläre Quantenphysik in einfachen Worten.',
    'Wie funktioniert maschinelles Lernen?',
    'Was sind die neuesten Trends in der Technologie?',
    'Chatte mit dem Agenten Michael Jordan',
    'Wir laden ein Video hoch und sagen ihm, wo er es schneiden soll.'
  ];

  // Verwendetes Modell
  final String modelUsed = 'Galacia 66';

  // Set zur Verwaltung der ausgewählten Gespräche
  Set<Conversation> selectedConversations = {};

  @override
  void dispose() {
    messageController.dispose();
    conversationTitleController.dispose();
    messageFocusNode.dispose();
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
          title: const Text('Bestätigen'),
          content: Text(
              'Möchten Sie die ausgewählten ${toDelete.length} Gespräche wirklich löschen?'),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  conversations.removeWhere((convo) => toDelete.contains(convo));
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
    conversationTitleController.text = convo.title;
    String? newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gespräch umbenennen'),
          content: TextField(
            controller: conversationTitleController,
            decoration: const InputDecoration(
              labelText: 'Neuer Titel',
            ),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Speichern'),
              onPressed: () =>
                  Navigator.of(context).pop(conversationTitleController.text),
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
        isBotTyping = true;
      });
      messageController.clear();

      // Fokus nach dem Senden der Nachricht setzen
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(messageFocusNode);
      });

      // Simulierte Bot-Antwort mit Verzögerung
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          selectedConversation!.messages
              .add(Message(sender: 'Bot', text: 'Antwort auf "$text"'));
          isBotTyping = false;
        });

        // Fokus nach der Bot-Antwort setzen
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(messageFocusNode);
        });
      });
    }
  }

  Widget _buildChatMessage(Message msg) {
    return Align(
      alignment:
          msg.sender == 'User' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.sender == 'User' ? Colors.blueAccent : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(msg.text),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Willkommen bei Galacia GPT',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hier sind einige Beispiele, was Sie fragen können:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...exampleQuestions.map((question) {
              return GestureDetector(
                onTap: () {
                  messageController.text = question;
                  _sendMessage(question);
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.question_answer, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 30),
            Text(
              'Verwendetes Modell: $modelUsed',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 300,
      color: Colors.grey[900],
      child: Column(
        children: [
          // Logo innerhalb des Sidebars
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logow.png',
                  height: 40,
                ),
                const SizedBox(width: 10),
                const Text(':GPT', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Neues Gespräch'),
            onTap: _createNewConversation,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                bool isSelected = selectedConversations.contains(convo);
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
                        icon: const Icon(Icons.edit),
                        onPressed: () => _renameConversation(convo),
                        tooltip: 'Gespräch umbenennen',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteConversations({convo});
                        },
                        tooltip: 'Gespräch löschen',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Button zum Löschen ausgewählter Gespräche
          if (selectedConversations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => _deleteConversations(selectedConversations),
                icon: const Icon(Icons.delete),
                label: Text('Löschen (${selectedConversations.length})'),
                style: ElevatedButton.styleFrom(
                  //primary: Colors.redAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Expanded(
      child: Column(
        children: [
          // Chat-Nachrichten oder Willkommensbildschirm
          Expanded(
            child: selectedConversation != null &&
                    selectedConversation!.messages.isNotEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...selectedConversation!.messages.map(_buildChatMessage),
                      if (isBotTyping)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  )
                : _buildWelcomeScreen(),
          ),
          // Eingabefeld
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.grey[800],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _createNewConversation,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: messageController,
                focusNode: messageFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Nachricht eingeben',
                  border: InputBorder.none,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: () {
              // Hier kannst du die Funktionalität für das Mikrofon hinzufügen
            },
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () => _sendMessage(messageController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Entferne die AppBar, da das Logo jetzt im Sidebar ist
      body: Row(
        children: [
          _buildSidebar(),
          _buildChatArea(),
        ],
      ),
    );
  }
}

class Conversation {
  String title;
  List<Message> messages;

  Conversation({required this.title}) : messages = [];
}

class Message {
  String sender;
  String text;

  Message({required this.sender, required this.text});
}
