import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme.dart';
import 'models/grocery_item.dart';
import 'providers/shopping_list_model.dart';
import 'screens/shopping_list_page.dart';
import 'screens/cart_tab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(GroceryItemAdapter());
  await Hive.openBox<GroceryItem>('grocery_box');
  await Hive.openBox('settings');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ShoppingListModel()..loadData(),
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
      home: const AppTabs(),
    );
  }
}

class AppTabs extends StatefulWidget {
  const AppTabs({super.key});
  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  int _currentIndex = 0;
  static const _pages = [
    ShoppingListPage(),
    CartPage(),
  ];

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
        ],
      ),
    );
  }
}
