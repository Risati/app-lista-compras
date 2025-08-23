import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/shopping_list.dart';
import 'providers/lists_provider.dart';
import 'screens/lists_menu_page.dart';

import 'theme.dart';
import 'models/grocery_item.dart';
import 'providers/shopping_list_model.dart';
import 'screens/shopping_list_page.dart';
import 'screens/cart_tab.dart';
import 'screens/favorites_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  // Registra os adapters antes de abrir as boxes
  Hive.registerAdapter(GroceryItemAdapter());
  Hive.registerAdapter(ShoppingListAdapter());

  // Abre as boxes
  await Hive.openBox<GroceryItem>('grocery_box');
  await Hive.openBox('settings');
  await Hive.openBox<GroceryItem>('favorites_box');
  await Hive.openBox<ShoppingList>('lists_box');

  // Inicializa o provider de listas e carrega as listas
  final listsProvider = ListsProvider();
  await listsProvider.loadLists();

  runApp(
    ChangeNotifierProvider(
      create: (_) => listsProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembra AÍ',
      debugShowCheckedModeBanner: false,
      theme: elegantTheme,
      home: const ListsMenuPage(), // Tela inicial: menu de listas
    );
  }
}

class AppTabs extends StatefulWidget {
  final ShoppingList list;
  const AppTabs({super.key, required this.list});

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChangeNotifierProvider(
        create: (_) => ShoppingListModel(widget.list),
        child: ShoppingListPage(list: widget.list),
      ),
      ChangeNotifierProvider(
        create: (_) => ShoppingListModel(widget.list),
        child: CartPage(list: widget.list),
      ),
      ChangeNotifierProvider(
        create: (_) => ShoppingListModel(widget.list),
        child: FavoritesPage(list: widget.list),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: secondaryColor,
        unselectedItemColor: Colors.white70,
        backgroundColor: primaryColor,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Carrinho',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}