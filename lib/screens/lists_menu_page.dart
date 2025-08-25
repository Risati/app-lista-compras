import 'package:flutter/material.dart';
import 'package:lista_elegante/theme.dart';
import 'package:provider/provider.dart';
import '../providers/lists_provider.dart';
import '../main.dart'; // Para AppTabs
import '../providers/theme_provider.dart';

class ListsMenuPage extends StatelessWidget {
  const ListsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
        title: const Column(
          children: [
            Text(
              'Lembra AÍ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              'Listas de Compras',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Colors.white,
          ),
          tooltip: 'Alternar tema',
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleMode();
          },
        ),
      ],
      ),
      body: listsProvider.lists.isEmpty
          ? const Center(child: Text('Nenhuma lista criada'))
          : ListView.builder(
              itemCount: listsProvider.lists.length,
              itemBuilder: (_, i) {
                final list = listsProvider.lists[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Theme.of(context).colorScheme.surface, // cor do card adaptada ao tema
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          _getIconForList(list.name),
                          color: Theme.of(context).colorScheme.onPrimary, // contraste automático
                        ),
                      ),
                      title: Text(
                        list.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Theme.of(context).colorScheme.secondary),
                            tooltip: 'Renomear lista',
                            onPressed: () async {
                              final newName = await _showRenameDialog(context, list.name);
                              if (newName != null && newName.isNotEmpty) {
                                await listsProvider.renameList(list, newName);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.error),
                            tooltip: 'Excluir lista',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Excluir lista?'),
                                  content: Text(
                                    'Tem certeza que deseja excluir "${list.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await listsProvider.removeList(list);
                              }
                            },
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AppTabs(list: list),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await _showNewListDialog(context);
          if (name != null && name.isNotEmpty) {
            await listsProvider.addList(name);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Criar'),
        backgroundColor: primaryColor,
        elevation: 6,
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

  Future<String?> _showRenameDialog(
      BuildContext context, String oldName) async {
    final controller = TextEditingController(text: oldName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renomear lista'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForList(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('churrasco')) return Icons.outdoor_grill;
    if (lower.contains('semanal') || lower.contains('semana')) {
      return Icons.calendar_today;
    }
    if (lower.contains('padaria') || lower.contains('pão')) {
      return Icons.bakery_dining;
    }
    if (lower.contains('frutas') || lower.contains('hortifruti')) {
      return Icons.local_grocery_store;
    }
    if (lower.contains('bebida') ||
        lower.contains('cerveja') ||
        lower.contains('vinho')) {
      return Icons.local_bar;
    }
    if (lower.contains('carnes') ||
        lower.contains('açougue') ||
        lower.contains('frango')) {
      return Icons.set_meal;
    }
    if (lower.contains('limpeza') || lower.contains('produtos de limpeza')) {
      return Icons.cleaning_services;
    }
    if (lower.contains('festa') || lower.contains('aniversário')) {
      return Icons.celebration;
    }
    if (lower.contains('farmácia') || lower.contains('remédio')) {
      return Icons.local_hospital;
    }
    if (lower.contains('lanche') || lower.contains('snack')) {
      return Icons.fastfood;
    }
    if (lower.contains('café') || lower.contains('manhã')) return Icons.coffee;
    if (lower.contains('vegano') || lower.contains('salada')) return Icons.eco;
    if (lower.contains('peixe') || lower.contains('marisco')) {
      return Icons.set_meal; // mesmo de carnes
    }
    if (lower.contains('doces') || lower.contains('sobremesa')) {
      return Icons.cake;
    }
    if (lower.contains('pet') || lower.contains('ração')) return Icons.pets;

    return Icons.list_alt; // fallback
  }
}
