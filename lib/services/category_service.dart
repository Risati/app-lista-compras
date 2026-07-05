import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CategoryService {
  static const String boxName = 'categorias';

  // Dicionário base (palavra-chave → categoria)
  static final Map<String, String> baseCategorias = {
    // 🍚 Grãos e Massas
    'arroz': 'Grãos',
    'feijão': 'Grãos',
    'lentilha': 'Grãos',
    'grão de bico': 'Grãos',
    'ervilha': 'Grãos',
    'macarrão': 'Massas',
    'espaguete': 'Massas',
    'penne': 'Massas',
    'fusilli': 'Massas',
    'lasanha': 'Massas',
    'farinha': 'Massas',
    'fubá': 'Massas',

    // 🥛 Laticínios e Frios
    'leite': 'Laticínios',
    'queijo': 'Laticínios',
    'requeijão': 'Laticínios',
    'manteiga': 'Laticínios',
    'iogurte': 'Laticínios',
    'danone': 'Laticínios',
    'creme de leite': 'Laticínios',
    'leite condensado': 'Laticínios',
    'presunto': 'Frios',
    'peito de peru': 'Frios',
    'salame': 'Frios',
    'mortadela': 'Frios',
    'salsicha': 'Frios',
    'linguiça': 'Frios',
    'bacon': 'Frios',

    // 🥩 Carnes
    'carne': 'Carnes',
    'patinho': 'Carnes',
    'alcatra': 'Carnes',
    'picanha': 'Carnes',
    'costela': 'Carnes',
    'frango': 'Carnes',
    'sassami': 'Carnes',
    'coxa': 'Carnes',
    'sobrecoxa': 'Carnes',
    'peito de frango': 'Carnes',
    'peixe': 'Carnes',
    'salmão': 'Carnes',
    'tilápia': 'Carnes',

    // 🥗 Hortifruti
    'batata': 'Hortifruti',
    'batata doce': 'Hortifruti',
    'cenoura': 'Hortifruti',
    'beterraba': 'Hortifruti',
    'abobrinha': 'Hortifruti',
    'tomate': 'Hortifruti',
    'alface': 'Hortifruti',
    'couve': 'Hortifruti',
    'rúcula': 'Hortifruti',
    'cebola': 'Hortifruti',
    'alho': 'Hortifruti',
    'pimentão': 'Hortifruti',
    'banana': 'Hortifruti',
    'maçã': 'Hortifruti',
    'uva': 'Hortifruti',
    'mamão': 'Hortifruti',
    'laranja': 'Hortifruti',
    'limão': 'Hortifruti',

    // 🍪 Padaria e Snacks
    'pão': 'Padaria',
    'bisnaguinha': 'Padaria',
    'pão de queijo': 'Padaria',
    'bolo': 'Padaria',
    'croissant': 'Padaria',
    'biscoito': 'Snacks',
    'bolacha': 'Snacks',
    'salgadinho': 'Snacks',
    'batata frita': 'Snacks',
    'batata palha': 'Snacks',
    'pipoca': 'Snacks',

    // 🍫 Doces
    'chocolate': 'Doces',
    'doce de leite': 'Doces',
    'nutella': 'Doces',
    'gelatina': 'Doces',
    'brownie': 'Doces',
    'bala': 'Doces',
    'pirulito': 'Doces',
    'bombom': 'Doces',

    // 🍷 Bebidas
    'água': 'Bebidas',
    'refrigerante': 'Bebidas',
    'coca-cola': 'Bebidas',
    'guaraná': 'Bebidas',
    'suco': 'Bebidas',
    'suco de laranja': 'Bebidas',
    'cerveja': 'Bebidas',
    'vinho': 'Bebidas',
    'whisky': 'Bebidas',
    'energético': 'Bebidas',
    'café': 'Bebidas',
    'cappuccino': 'Bebidas',
    'nescau': 'Bebidas',
    'achocolatado': 'Bebidas',

    // 🧼 Higiene e Limpeza
    'shampoo': 'Higiene',
    'condicionador': 'Higiene',
    'sabonete': 'Higiene',
    'desodorante': 'Higiene',
    'creme dental': 'Higiene',
    'escova de dente': 'Higiene',
    'fio dental': 'Higiene',
    'papel higiênico': 'Higiene',
    'absorvente': 'Higiene',
    'detergente': 'Limpeza',
    'amaciante': 'Limpeza',
    'sabão em pó': 'Limpeza',
    'lava roupas': 'Limpeza',
    'alvejante': 'Limpeza',
    'desinfetante': 'Limpeza',
    'alcool': 'Limpeza',
    'multiuso': 'Limpeza',
    'veja': 'Limpeza',
    'diabo verde': 'Limpeza',

    // 🐶 Pets
    'ração': 'Pets',
    'ração cachorro': 'Pets',
    'ração gato': 'Pets',
    'petisco': 'Pets',
  };

  // Cores padrão para cada categoria
  static final Map<String, Color> categoriaCores = {
    'Grãos': Colors.brown,
    'Massas': Colors.orange,
    'Mercearia': Colors.amber,
    'Laticínios': Colors.blue,
    'Frios': Colors.blueGrey,
    'Carnes': Colors.red,
    'Limpeza': Colors.teal,
    'Higiene': Colors.purple,
    'Padaria': Colors.yellow,
    'Snacks': Colors.deepOrange,
    'Doces': Colors.pink,
    'Bebidas': Colors.lightBlue,
    'Pets': Colors.green,
    'Outros': Colors.grey,
  };

  /// Obtém categoria de um produto (base → Hive → fallback)
  static Future<String> getCategoria(String produto) async {
    final box = await Hive.openBox(boxName);
    final lowerProduto = produto.toLowerCase();

    // 1. Busca no dicionário base por palavra exata
    final palavras = lowerProduto.split(RegExp(r'[\s,;.-]+'));
    for (final palavra in palavras) {
      if (baseCategorias.containsKey(palavra)) {
        return baseCategorias[palavra]!;
      }
    }

    // 2. Busca no Hive (aprendizado do usuário)
    for (final key in box.keys) {
      if (key is String && key.contains(lowerProduto)) {
        final savedCategoria = box.get(key);
        if (savedCategoria != null && savedCategoria is String) {
          return savedCategoria;
        }
      }
    }

    // 3. Fallback -> Outros
    return 'Outros';
  }

  /// Salva categoria escolhida pelo usuário
  static Future<void> salvarCategoria(String produto, String categoria) async {
    final box = await Hive.openBox(boxName);
    final lowerProduto = produto.toLowerCase();
    await box.put(lowerProduto, categoria);
  }

  /// Edita categoria aprendida de um produto
  static Future<void> editarCategoria(
      String produto, String novaCategoria) async {
    await salvarCategoria(produto, novaCategoria);
  }

  /// Remove categoria aprendida de um produto
  static Future<void> removerCategoria(String produto) async {
    final box = await Hive.openBox(boxName);
    final lowerProduto = produto.toLowerCase();
    await box.delete(lowerProduto);
  }

  /// Retorna a cor associada à categoria
  static Color getCorCategoria(String categoria) {
    return categoriaCores[categoria] ?? Colors.grey;
  }

  /// Lista todas as categorias aprendidas pelo usuário
  static Future<Map<String, String>> getCategoriasAprendidas() async {
    final box = await Hive.openBox(boxName);
    return Map<String, String>.from(box.toMap());
  }

  /// Agrupa e ordena uma lista de produtos por categoria
  static Future<Map<String, List<String>>> agruparPorCategoria(
      List<String> produtos) async {
    final Map<String, List<String>> mapaCategorias = {};

    for (final produto in produtos) {
      final categoria = await getCategoria(produto);

      if (!mapaCategorias.containsKey(categoria)) {
        mapaCategorias[categoria] = [];
      }
      mapaCategorias[categoria]!.add(produto);
    }

    // Ordenar categorias alfabeticamente
    final categoriasOrdenadas = mapaCategorias.keys.toList()..sort();

    // Criar novo mapa com ordem garantida
    final Map<String, List<String>> resultadoOrdenado = {
      for (final cat in categoriasOrdenadas)
        cat: (mapaCategorias[cat]!..sort()) // ordena produtos dentro da categoria
    };

    return resultadoOrdenado;
  }
}
