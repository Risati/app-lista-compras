import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/barcode_service.dart';
import '../providers/lists_provider.dart';
import '../models/shopping_list.dart';

class BarcodeScannerPage extends StatefulWidget {
  final ShoppingList list;
  final ListsProvider model; // Mudou de provider para model

  const BarcodeScannerPage({
    super.key,
    required this.list,
    required this.model, // Mudou de provider para model
  });

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isProcessing = false;
  MobileScannerController controller = MobileScannerController();

  void _handleBarcode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final product = await BarcodeService.fetchProduct(code);
      if (!mounted) return;

      String name = code;
      if (product != null) {
        if (product.name != null && product.brand != null) {
          name = '${product.name} - ${product.brand}';
        } else {
          name = product.name ?? product.brand ?? code;
        }
      }

      widget.model.addItemToList(widget.list, name, 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicionado: $name')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar o código: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear código'),
        // Remove todo o actions: []
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first.rawValue;
              if (barcode != null) _handleBarcode(barcode);
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
