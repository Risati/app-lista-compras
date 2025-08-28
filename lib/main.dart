import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/shopping_list.dart';
import 'providers/lists_provider.dart';
import 'screens/lists_menu_page.dart';
import '../core/theme/app_theme.dart';
import 'models/grocery_item.dart';
import 'screens/shopping_list_page.dart';
import 'screens/cart_tab.dart';
import 'screens/favorites_page.dart';
import 'providers/theme_provider.dart';
import 'providers/report_provider.dart';
import 'core/theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Registra os adapters
  Hive.registerAdapter(GroceryItemAdapter());
  Hive.registerAdapter(ShoppingListAdapter());

  // Abre as boxes
  await Hive.openBox<GroceryItem>('grocery_box');
  await Hive.openBox('settings');
  await Hive.openBox<GroceryItem>('favorites_box');
  await Hive.openBox<ShoppingList>('lists_box');

  // Inicializa provider das listas
  final listsProvider = ListsProvider();
  await listsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => listsProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Lembra AÍ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.mode,
      home: const ListsMenuPage(),
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
      ShoppingListPage(list: widget.list),
      CartPage(list: widget.list),
      FavoritesPage(list: widget.list),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.white70,
        backgroundColor: AppColors.primary,
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
