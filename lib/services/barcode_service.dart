import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductData {
  final String? name;
  final String? brand;
  final String? imageUrl;
  ProductData({this.name, this.brand, this.imageUrl});
}

class BarcodeService {
  // Consulta OpenFoodFacts
  static Future<ProductData?> fetchProduct(String barcode,
      {bool staging = false}) async {
    try {
      final base = staging
          ? 'https://world.openfoodfacts.net'
          : 'https://world.openfoodfacts.org';
      final url = Uri.parse(
          '$base/api/v0/product/$barcode.json?fields=product_name,brands,image_small_url,image_url');
      final headers = {
        'User-Agent':
            'Lembra AI/1.0 (danilosouza725@gmail.com/felipe.dalpiccol@gmail.com)',
        if (staging)
          'Authorization': 'Basic ${base64Encode(utf8.encode('off:off'))}',
      };
      final res = await http.get(url, headers: headers);
      if (res.statusCode != 200) return null;
      final Map<String, dynamic> json = jsonDecode(res.body);
      if (json['status'] != 1) return null;
      final product = json['product'] as Map<String, dynamic>;

      final name = (product['product_name'] as String?)?.trim() ??
          (product['generic_name'] as String?)?.trim() ??
          (product['product_name_en'] as String?)?.trim() ??
          (product['generic_name_en'] as String?)?.trim() ??
          (product['brands'] as String?)?.split(',').first.trim();

      final image = product['image_small_url'] as String? ??
          product['image_url'] as String? ??
          (product['images'] is Map
              ? (product['images'] as Map).values.first is Map
                  ? ((product['images'] as Map).values.first as Map)['small']
                      as String?
                  : null
              : null);

      return ProductData(
          name: name,
          brand: (product['brands'] as String?)?.trim(),
          imageUrl: image);
    } catch (_) {
      return null;
    }
  }
}
