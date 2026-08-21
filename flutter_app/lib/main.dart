import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TechDeckApp());
}

class TechDeckApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechDeck HQ (Prototype)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    FeedPage(),
    ChatPage(),
    TipsPage(),
    BunkerPage(),
    AdminIngestPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TechDeck HQ'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Tips'),
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'Bunker'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Feed Page (mocked posts) ---
class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Map<String, String>> posts = [
    {
      'id': '1',
      'text': 'Welcome to TechDeck — daily tips for netizens!',
      'source': 'admin',
      'time': '2026-08-21'
    },
    {
      'id': '2',
      'text': 'Security tip: use a password manager and enable 2FA.',
      'source': 'whatsapp',
      'time': '2026-08-20'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // In prototype, refresh will just wait
        await Future.delayed(Duration(seconds: 1));
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(post['text']!),
              subtitle: Text('${post['source']} • ${post['time']}'),
            ),
          );
        },
      ),
    );
  }
}

// --- Chat Page (AI Assistant) ---
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool _loading = false;

  Future<void> sendPrompt(String prompt) async {
    setState(() => _loading = true);
    messages.add({'role': 'user', 'text': prompt});
    // Call the openai-proxy (placeholder). Update the URL when you deploy functions.
    final apiUrl = 'https://us-central1-your-firebase-project.cloudfunctions.net/openaiProxy';

    try {
      final resp = await http.post(Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'}, body: jsonEncode({'prompt': prompt}));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content = data['text'] ?? 'No response';
        messages.add({'role': 'assistant', 'text': content});
      } else {
        messages.add({'role': 'assistant', 'text': 'AI service error (prototype).'});
      }
    } catch (e) {
      messages.add({'role': 'assistant', 'text': 'Network error or proxy not configured.'});
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isUser = msg['role'] == 'user';
              return ListTile(
                title: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                        child: Text(msg['text']!))),
              );
            },
          ),
        ),
        if (_loading) LinearProgressIndicator(),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Ask TechDeck AI...')),
              ),
              IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final prompt = _controller.text.trim();
                    if (prompt.isNotEmpty) {
                      _controller.clear();
                      sendPrompt(prompt);
                    }
                  })
            ],
          ),
        )
      ],
    );
  }
}

// --- Tips Page (mock) ---
class TipsPage extends StatelessWidget {
  final List<String> tips = [
    'Tip: Use strong, unique passwords for each account.',
    'Tip: Keep your software updated.',
    'Tip: Be cautious with links from unknown senders.'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tips.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: Icon(Icons.lightbulb_outline),
            title: Text(tips[index]),
          ),
        );
      },
    );
  }
}

// --- Safety Bunker (prototype: local encrypted stub) ---
class BunkerPage extends StatefulWidget {
  @override
  _BunkerPageState createState() => _BunkerPageState();
}

class _BunkerPageState extends State<BunkerPage> {
  List<String> items = [];
  final TextEditingController _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      items = prefs.getStringList('bunker_items') ?? [];
    });
  }

  Future<void> _addItem(String text) async {
    // Prototype: store in shared prefs (in full app this will be encrypted)
    final prefs = await SharedPreferences.getInstance();
    items.insert(0, text);
    await prefs.setStringList('bunker_items', items);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: TextField(controller: _itemController, decoration: InputDecoration(hintText: 'Add secure note...'))),
              ElevatedButton(
                  onPressed: () {
                    final t = _itemController.text.trim();
                    if (t.isNotEmpty) {
                      _itemController.clear();
                      _addItem(t);
                    }
                  },
                  child: Text('Save'))
            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(title: Text(items[index])),
        ))
      ],
    );
  }
}

// --- Admin Ingest (simple in-app editor) ---
class AdminIngestPage extends StatefulWidget {
  @override
  _AdminIngestPageState createState() => _AdminIngestPageState();
}

class _AdminIngestPageState extends State<AdminIngestPage> {
  final TextEditingController _postController = TextEditingController();
  List<Map<String, String>> _localPosts = [];

  void _publish() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    final post = {'id': DateTime.now().toIso8601String(), 'text': text, 'source': 'admin', 'time': DateTime.now().toIso8601String().split('T').first};
    setState(() {
      _localPosts.insert(0, post);
      _postController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created (local prototype)')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _postController,
            decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Paste TechDeck content or write a post'),
            minLines: 3,
            maxLines: 6,
          ),
          SizedBox(height: 8),
          ElevatedButton(onPressed: _publish, child: Text('Publish (local)')),
          Expanded(
              child: ListView.builder(
            itemCount: _localPosts.length,
            itemBuilder: (context, i) {
              final p = _localPosts[i];
              return ListTile(title: Text(p['text']!), subtitle: Text(p['time']!));
            },
          ))
        ],
      ),
    );
  }
}
