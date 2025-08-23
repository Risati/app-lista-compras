import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lists_provider.dart';
import '../models/shopping_list.dart';
import '../main.dart'; // Para AppTabs

class ListsMenuPage extends StatelessWidget {
  const ListsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Listas')),
      body: listsProvider.lists.isEmpty
          ? const Center(child: Text('Nenhuma lista criada'))
          : ListView.builder(
              itemCount: listsProvider.lists.length,
              itemBuilder: (_, i) {
                final list = listsProvider.lists[i];
                return ListTile(
                  title: Text(list.name),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppTabs(list: list),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final name = await _showNewListDialog(context);
          if (name != null && name.isNotEmpty) {
            await listsProvider.addList(name);
          }
        },
      ),
    );
  }

  Future<String?> _showNewListDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nome da nova lista'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}