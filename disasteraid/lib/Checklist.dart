import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Box box;
  List<String> _items = [];
  List<bool> _checkedItems = [];

  @override
  void initState() {
    super.initState();
    box = Hive.box('checklistBox');
    _loadChecklist();
  }

  void _loadChecklist() {
    _items = List<String>.from(box.get('items', defaultValue: []));
    _checkedItems = List<bool>.from(
      box.get('checks', defaultValue: List<bool>.filled(_items.length, false)),
    );
    setState(() {});
  }

  void _saveChecklist() {
    box.put('items', _items);
    box.put('checks', _checkedItems);
  }

  void _addItem(String newItem) {
    setState(() {
      _items.add(newItem);
      _checkedItems.add(false);
    });
    _saveChecklist();
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      _checkedItems.removeAt(index);
    });
    _saveChecklist();
  }

  void _toggleCheck(int index, bool value) {
    setState(() {
      _checkedItems[index] = value;
    });
    _saveChecklist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Checklist')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                  leading: Checkbox(
                    value: _checkedItems[index],
                    onChanged: (bool? value) {
                      _toggleCheck(index, value ?? false);
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
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
                          onPressed: () => Navigator.of(context).pop(),
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
