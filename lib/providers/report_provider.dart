import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../models/shopping_list_report.dart';

class ReportProvider extends ChangeNotifier {
  Future<String> generatePDF(ShoppingListReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Lista de Compras',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Lista: ${report.list.name}'),
            pw.Text('Data: ${report.formattedDate}'),
            pw.SizedBox(height: 10),
            pw.Text('Resumo:'),
            pw.Text('Total de itens: ${report.totalItems}'),
            pw.Text('Itens comprados: ${report.purchasedItems}'),
            pw.Text(
                'Taxa de conclusão: ${report.completionRate.toStringAsFixed(1)}%'),
            pw.Text('Custo total: R\$ ${report.totalCost.toStringAsFixed(2)}'),
            pw.SizedBox(height: 20),
            _buildItemsTable(report),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/relatorio_${report.list.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _buildItemsTable(ShoppingListReport report) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Text('Item'),
            pw.Text('Qtd'),
            pw.Text('Preço'),
            pw.Text('Total'),
            pw.Text('Status'),
          ],
        ),
        ...report.list.items.map((item) => pw.TableRow(
              children: [
                pw.Text(item.name),
                pw.Text(item.quantity.toString()),
                pw.Text('R\$ ${item.price.toStringAsFixed(2)}'),
                pw.Text(
                    'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}'),
                pw.Text(item.purchased ? 'Comprado' : 'Pendente'),
              ],
            )),
      ],
    );
  }
}
