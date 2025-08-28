import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lists_provider.dart';
import '../main.dart';
import '../providers/theme_provider.dart';
import '../models/shopping_list_report.dart';
import '../providers/report_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/shopping_list.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../core/constants/strings.dart';

class ListsMenuPage extends StatelessWidget {
  const ListsMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 4,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
      Text(
        Strings.appName,
        style: AppTextStyles.titleSmall(context).copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        )
      ),
      Text(
        Strings.appSubtitle,
        style: AppTextStyles.titleSmall(context).copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
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
            onPressed: () =>
                Provider.of<ThemeProvider>(context, listen: false).toggleMode(),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // TabBar moderna estilo "pill"
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white.withOpacity(0.25),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.playlist_add_check),
                    text: Strings.titleActiveList,
                  ),
                  Tab(
                    icon: Icon(Icons.done_all),
                    text: Strings.titleCompletedLists,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Ativas
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: listsProvider.activeLists.isEmpty
                        ? const _EmptyState(message: Strings.msgNoActiveList)
                        : _buildListView(context, listsProvider.activeLists),
                  ),
                  // Concluídas
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: listsProvider.completedLists.isEmpty
                        ? const _EmptyState(
                            message: Strings.msgNoCompletedLists,
                          )
                        : _buildListView(
                            context,
                            listsProvider.completedLists,
                            completed: true,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        icon: const Icon(Icons.add),
        label: const Text(Strings.btnCreate),
        elevation: 6,
      ),
    );
  }

  Future<void> _showCreateOptions(BuildContext context) async {
    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nova lista', style: AppTextStyles.titleMedium(context)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Ex.: Lista semanal, Churrasco, Hortifruti...',
                  prefixIcon: Icon(Icons.list_alt),
                ),
                onSubmitted: (_) => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  await listsProvider.addList(name);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check),
                label: const Text('Criar'),
              ),
              const SizedBox(height: 8),
              Text(
                'Dica: você pode definir o orçamento na próxima tela.',
                style: AppTextStyles.bodySmall(context)
                    .copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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

  Future<void> _generateReport(BuildContext context, ShoppingList list) async {
    final report = ShoppingListReport.fromShoppingList(list);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final pdfPath = await reportProvider.generatePDF(report);
      await OpenFile.open(pdfPath);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao gerar relatório: $e')),
      );
    }
  }

  Widget _buildListView(BuildContext context, List<ShoppingList> lists,
      {bool completed = false}) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: lists.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final list = lists[i];
        final isCompleted = completed || list.isCompleted;

        final baseColor = theme.colorScheme.surface;
        final completedColor = theme.brightness == Brightness.dark
            ? Colors.green.withOpacity(0.12)
            : Colors.green.withOpacity(0.08);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isCompleted ? completedColor : baseColor,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      _getIconForList(list.name),
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  if (isCompleted)
                    const Positioned(
                      right: -2,
                      bottom: -2,
                      child: Icon(Icons.check_circle, size: 18, color: Colors.green),
                    ),
                ],
              ),
              title: Text(
                list.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  color: isCompleted ? theme.hintColor : null,
                ),
              ),
              subtitle: isCompleted
                  ? Text('Concluída',
                      style: AppTextStyles.bodySmall(context)
                          .copyWith(color: Colors.green[700]))
                  : null,
              // Trailing mais limpo: botão de relatório + menu flutuante
              trailing: Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Remove o botão de relatório daqui

                PopupMenuButton<String>(
                  tooltip: 'Opções',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) async {
                    if (value == 'report') {
                      await _generateReport(context, list);
                    } else if (value == 'rename') {
                      final newName = await _showRenameDialog(context, list.name);
                      if (newName != null && newName.isNotEmpty) {
                        await Provider.of<ListsProvider>(context, listen: false)
                            .renameList(list, newName);
                      }
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir lista?'),
                          content: Text('Tem certeza que deseja excluir "${list.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        if (!context.mounted) return;
                        await Provider.of<ListsProvider>(context, listen: false)
                            .removeList(list);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    if (isCompleted)
                      const PopupMenuItem(
                        value: 'report',
                        child: ListTile(
                          leading: Icon(Icons.assessment),
                          title: Text('Relatório'),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'rename',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Renomear'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Excluir'),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),

                Icon(Icons.arrow_forward_ios,
                    color: theme.colorScheme.primary, size: 18),
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
    );
  }

  IconData _getIconForList(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('churrasco')) return Icons.outdoor_grill;
    if (lower.contains('semanal') || lower.contains('semana')) return Icons.calendar_today;
    if (lower.contains('padaria') || lower.contains('pão')) return Icons.bakery_dining;
    if (lower.contains('frutas') || lower.contains('hortifruti')) return Icons.local_grocery_store;
    if (lower.contains('bebida') || lower.contains('cerveja') || lower.contains('vinho')) return Icons.local_bar;
    if (lower.contains('carnes') || lower.contains('açougue') || lower.contains('frango')) return Icons.set_meal;
    if (lower.contains('limpeza') || lower.contains('produtos de limpeza')) return Icons.cleaning_services;
    if (lower.contains('festa') || lower.contains('aniversário')) return Icons.celebration;
    if (lower.contains('farmácia') || lower.contains('remédio')) return Icons.local_hospital;
    if (lower.contains('lanche') || lower.contains('snack')) return Icons.fastfood;
    if (lower.contains('café') || lower.contains('manhã')) return Icons.coffee;
    if (lower.contains('vegano') || lower.contains('salada')) return Icons.eco;
    if (lower.contains('peixe') || lower.contains('marisco')) return Icons.set_meal;
    if (lower.contains('doces') || lower.contains('sobremesa')) return Icons.cake;
    if (lower.contains('pet') || lower.contains('ração')) return Icons.pets;
    return Icons.list_alt;
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 48, color: theme.colorScheme.primary.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('Crie uma nova lista com o botão +',
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}
