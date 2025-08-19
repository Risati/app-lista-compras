/// Stub de categorização automática usando IA (Gemini)
class AIService {
  static Future<String> categorize(String itemName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = itemName.toLowerCase();
    if (lower.contains('leite') || lower.contains('queijo')) {
      return 'Laticínios';
    }
    if (lower.contains('pão') || lower.contains('bolo')) {
      return 'Padaria';
    }
    if (lower.contains('arroz') || lower.contains('feijão')) {
      return 'Mercearia';
    }
    return 'Outros';
  }
}