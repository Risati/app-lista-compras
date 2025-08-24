import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../providers/reports_provider.dart';
import '../models/report_snapshot.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});
  @override
  Widget build(BuildContext context) {
    final reportsProv = context.watch<ReportsProvider>();
    final reports = reportsProv.getAllReports();
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (_, i) {
          final r = reports[i];
          return ListTile(
            title: Text(r.marketName ?? 'Sem mercado'),
            subtitle: Text(r.date.toLocal().toString().split(' ').first),
            trailing: Text(currency.format(r.total)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ReportDetailPage(report: r)),
            ),
          );
        },
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  final ReportSnapshot report;
  const ReportDetailPage({required this.report, super.key});
  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Scaffold(
      appBar: AppBar(title: Text(report.marketName ?? 'Relatório'), actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Exportar PDF',
          onPressed: () async {
            final bytes =
                await context.read<ReportsProvider>().buildReportPdf(report);
            await Printing.sharePdf(
                bytes: bytes, filename: 'relatorio_${report.id}.pdf');
          },
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          tooltip: 'Exportar CSV',
          onPressed: () async {
            final csv = context.read<ReportsProvider>().exportReportCsv(report);
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/relatorio_${report.id}.csv');
            await file.writeAsString(csv, encoding: utf8);
            print('CSV content: $csv');
            print('File path: ${file.path}');
            print('File exists: ${await file.exists()}');
            // ignore: deprecated_member_use
            await Share.shareXFiles([XFile(file.path)],
                text: 'Relatório ${report.marketName ?? ''}');
          },
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${report.date.toLocal()}'),
            const SizedBox(height: 8),
            Text('Total: ${currency.format(report.total)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: report.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final it = report.items[i];
                  return ListTile(
                    title: Text(it.name),
                    subtitle: Text(
                        '${it.quantity} x ${currency.format(it.unitPrice)}'),
                    trailing: Text(currency.format(it.subtotal)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
