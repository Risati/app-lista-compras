import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/barcode_service.dart';
import '../providers/shopping_list_model.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isProcessing = false;
  MobileScannerController controller = MobileScannerController();

  void _handleBarcode(String code) async {
    if (_isProcessing) return;

    // Parar o scanner após leitura
    await controller.stop();
    setState(() => _isProcessing = true);

    final product = await BarcodeService.fetchProduct(code);
    if (!mounted) return; // <-- evita uso de BuildContext inválido

    // Adicionando o nome do produto + marca
    // E.g. Creme de Leite Leve UHT - Mococa
    String name = code;
    if (product != null) {
      if (product.name != null && product.brand != null) {
        name = '${product.name} - ${product.brand}';
      } else {
        name = product.name ?? product.brand ?? code;
      }
    }

    Provider.of<ShoppingListModel>(context, listen: false).addQuick(name, 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adicionado: $name')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first.rawValue;
              if (barcode != null) _handleBarcode(barcode);
            },
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
