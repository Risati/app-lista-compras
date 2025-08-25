import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/shopping_list.dart';
import '../providers/shopping_list_model.dart';
import '../models/grocery_item.dart';
import 'barcode_scanner_page.dart';
import '../providers/theme_provider.dart';

class ShoppingListPage extends StatefulWidget {
  final ShoppingList list;
  const ShoppingListPage({super.key, required this.list});
  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  // Formatter que formata enquanto digita (1 -> R$ 0,01 ; 1050 -> R$ 10,50)
  final TextInputFormatter currencyFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final value = int.parse(digits);
    final formatted = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
        .format(value / 100);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });

  void _showEditItemDialog(
      BuildContext context, ShoppingListModel model, GroceryItem item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(text: currency.format(item.price));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar item'),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [currencyFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final q = int.tryParse(qtyCtrl.text) ?? item.quantity;
              final digits = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
              final p = digits.isEmpty ? 0.0 : int.parse(digits) / 100.0;
              model.updateItem(item, qty: q, price: p);
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListModel>(
      builder: (_, model, __) {
        final total = model.items.fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        final totalGasto = model.items
            .where((item) => item.purchased)
            .fold<double>(
                0.0, (sum, item) => sum + (item.price * item.quantity));
        final itensRestantes =
            model.items.where((item) => !item.purchased).length;

        final filtered = model.available
            .where((item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Lembra AÍ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                Text(
                  'Listas de Compras',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              // Botão alternar tema
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Theme.of(context).appBarTheme.iconTheme?.color ??
                      Theme.of(context).colorScheme.onPrimary,
                ),
                tooltip: 'Alternar tema',
                onPressed: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleMode();
                },
              ),

              // Busca
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _showSearch ? 220 : 48,
                child: Row(
                  children: [
                    if (_showSearch)
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar...',
                            hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withAlpha(178),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (query) {
                            setState(() => _searchQuery = query);
                          },
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        _showSearch ? Icons.close : Icons.search,
                        color: Theme.of(context).appBarTheme.iconTheme?.color ??
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_showSearch) {
                            _searchQuery = '';
                            _searchCtrl.clear();
                          }
                          _showSearch = !_showSearch;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Barra inferior
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        model.isAsc
                            ? Icons.sort_by_alpha
                            : Icons.sort_by_alpha_outlined,
                        color: Theme.of(context).appBarTheme.iconTheme?.color ??
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'Ordenar lista',
                      onPressed: model.toggleSort,
                    ),

                    // Centraliza o orçamento
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _showBudgetDialog(context, model),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white10
                                  : Colors.blueAccent.withAlpha(
                                      178), // mais visível no light
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 18,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors
                                          .white, // ícone mais visível no light
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Orçamento: ${currency.format(widget.list.budget)}',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.white, // texto mais visível
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Consumer<ShoppingListModel>(
            builder: (context, model, _) => FloatingActionButton(
              tooltip: 'Escanear código de barras',
              heroTag: 'scan_fab',
              child: const Icon(Icons.qr_code_scanner),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BarcodeScannerPage(
                    list: widget.list,
                    model: model, // Usa o modelo do Consumer
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.blue),
                          const SizedBox(height: 4),
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currency.format(total),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(height: 4),
                          const Text('Gasto',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            currency.format(totalGasto),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.pending_actions,
                              color: Colors.orange[700]),
                          const SizedBox(height: 4),
                          const Text('Restantes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '$itensRestantes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Produto',
                        ),
                        onSubmitted: (_) => _add(model),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _qtyCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Qtd',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onSubmitted: (_) => _add(model),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _add(model),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    return Dismissible(
                      key: ValueKey(item.name + item.quantity.toString()),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 32),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 32),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Swipe para a direita: marcar como comprado
                          model.togglePurchased(item);
                          return false; // Não remove visualmente, só marca
                        } else if (direction == DismissDirection.endToStart) {
                          // Swipe para a esquerda: remover sem confirmação
                          model.remove(item);
                          return true;
                        }
                        return false;
                      },
                      child: Card(
                        child: ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          tileColor: Theme.of(context)
                              .colorScheme
                              .surface, // se adapta ao tema
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: GestureDetector(
                            onTap: () =>
                                _showEditNameDialog(context, model, item),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          subtitle: Wrap(
                            children: [
                              Text(
                                'Qtd: ${item.quantity}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                currency.format(item.price),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                currency.format(item.quantity * item.price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // destaca o total
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  item.isFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: item.isFavorite
                                      ? Colors
                                          .amber // mantém destaque no favorito
                                      : Theme.of(context)
                                          .iconTheme
                                          .color
                                          ?.withAlpha(153),
                                ),
                                onPressed: () {
                                  Provider.of<ShoppingListModel>(context,
                                          listen: false)
                                      .toggleFavorite(item);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color, // pega do tema
                                ),
                                onPressed: () =>
                                    _showEditItemDialog(context, model, item),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _add(ShoppingListModel model) {
    FocusScope.of(context).unfocus();
    final name = _nameCtrl.text.trim();
    final qty = int.tryParse(_qtyCtrl.text) ?? 1;
    if (name.isEmpty) return;
    model.addQuick(name, qty);
    _nameCtrl.clear();
    _qtyCtrl.text = '1';
  }

    void _showBudgetDialog(BuildContext context, ShoppingListModel model) {
    final ctrl = TextEditingController(text: currency.format(widget.list.budget));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajustar Orçamento'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [currencyFormatter],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final digits = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
              final v = digits.isEmpty ? 0.0 : int.parse(digits) / 100.0;
              setState(() {
                widget.list.budget = v; // Atualiza o orçamento da lista atual
              });
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, ShoppingListModel model, GroceryItem item) {
    final ctrl = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                model.updateItem(item, name: newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
