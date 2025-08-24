import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/report_snapshot.dart';
import '../models/report_item.dart';
import '../providers/shopping_list_model.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider();

  // Gera ReportSnapshot a partir do ShoppingListModel (sem I/O)
  ReportSnapshot generateFromModel(ShoppingListModel model,
      {String? marketName}) {
    final items = model.cart; // itens marcados como comprados
    final reportItems = items
        .map((i) => ReportItem(
              name: i.name,
              quantity: i.quantity,
              unitPrice: i.price,
              subtotal: i.price * i.quantity,
              category: i.category,
            ))
        .toList();

    final total = reportItems.fold<double>(0.0, (s, r) => s + r.subtotal);

    return ReportSnapshot(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      listId: model.list.name, // identificador simples (nome da lista)
      date: DateTime.now(),
      marketName: marketName,
      total: total,
      budget: model.budget,
      items: reportItems,
      note: null,
    );
  }

  // Salva o snapshot na box 'reports_box'
  Future<void> saveReport(ReportSnapshot report) async {
    final box = Hive.box<ReportSnapshot>('reports_box');
    await box.add(report);
    notifyListeners();
  }

  // Retorna todos os reports ou só de uma lista específica
  List<ReportSnapshot> getAllReports({String? listId}) {
    final box = Hive.box<ReportSnapshot>('reports_box');
    final all = box.values.cast<ReportSnapshot>().toList();
    if (listId == null) return all;
    return all.where((r) => r.listId == listId).toList();
  }

  // Deleta um report pelo id (procura pela propriedade id do objeto)
  Future<void> deleteReport(String id) async {
    final box = Hive.box<ReportSnapshot>('reports_box');
    dynamic foundKey;
    for (var k in box.keys) {
      final v = box.get(k) as ReportSnapshot;
      if (v.id == id) {
        foundKey = k;
        break;
      }
    }
    if (foundKey != null) {
      await box.delete(foundKey);
      notifyListeners();
    }
  }

  // Exporta CSV (string) do report
  String exportReportCsv(ReportSnapshot report) {
    final sb = StringBuffer();
    sb.writeln('name,quantity,unit_price,subtotal,category');
    for (var it in report.items) {
      final unit = it.unitPrice.toStringAsFixed(2).replaceAll('.', ',');
      final sub = it.subtotal.toStringAsFixed(2).replaceAll('.', ',');
      sb.writeln(
          '"${it.name}",${it.quantity},"$unit","$sub","${it.category ?? ''}"');
    }
    sb.writeln();
    sb.writeln('Total;${report.total.toStringAsFixed(2).replaceAll('.', ',')}');
    return sb.toString();
  }

  Future<Uint8List> buildReportPdf(ReportSnapshot report) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(report.marketName ?? 'Relatório')),
          pw.Text('Data: ${report.date.toLocal()}'),
          pw.SizedBox(height: 8),
          pw.Text('Total: ${currency.format(report.total)}',
              style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Produto', 'Qtd', 'Unit', 'Subtotal', 'Categoria'],
            data: report.items
                .map((it) => [
                      it.name,
                      it.quantity.toString(),
                      currency.format(it.unitPrice),
                      currency.format(it.subtotal),
                      it.category ?? '',
                    ])
                .toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
