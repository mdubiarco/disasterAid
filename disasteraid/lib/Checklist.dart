import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Checklist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigating to ListPage (Checklist)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListPage()),
            );
          },
          child: const Text('Go to Emergency Checklist'),
        ),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // List of items for the checklist
  List<String> _items = [
    "A supply of water",
    "A supply of canned food",
    "Flashlight and batteries",
  ];

  // Track whether each item is checked
  List<bool> _checkedItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize the checkedItems list with false for each item
    _checkedItems = List.generate(_items.length, (index) => false);
  }

  // Function to handle adding a new item to the checklist
  void _addItem(String newItem) {
    setState(() {
      _items.add(newItem); 
      _checkedItems.add(false); 
    });
  }

  // Function to handle deleting an item from the checklist
  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      _checkedItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Checklist')),
      body: Column(
        children: [
          // Displaying the checklist
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                  leading: Checkbox(
                    value: _checkedItems[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _checkedItems[index] = value!;
                      });
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteItem(index);
                    },
                  ),
                );
              },
            ),
          ),
          // Button to add a new item
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Show a dialog to input a new checklist item
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add New Item'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'Enter item here'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              _addItem(controller.text);
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Add New Item'),
            ),
          ),
        ],
      ),
    );
  }
}