import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class ThongKeScreen extends StatelessWidget {
  Future<Map<String, int>> thongKeSanPham() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('products').get();
    Map<String, int> loaiSanPhamCount = {};

    for (var doc in snapshot.docs) {
      String loai = doc['loaisp'];
      loaiSanPhamCount[loai] = (loaiSanPhamCount[loai] ?? 0) + 1;
    }

    return loaiSanPhamCount;
  }

  Future<void> xuatPDF(BuildContext context) async {
    Map<String, int> data = await thongKeSanPham();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Thống kê sản phẩm", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            for (var entry in data.entries)
              pw.Text("${entry.key}: ${entry.value} sản phẩm", style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    Directory? directory = await getExternalStorageDirectory();
    String path = "${directory!.path}/Documents";
    Directory(path).createSync(recursive: true);
    File file = File("$path/thong_ke.pdf");

    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã lưu PDF tại: $path/thong_ke.pdf")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Nút mũi tên quay lại
          onPressed: () => Navigator.pushNamed(context, '/home'),

        ),
        title: Text("Thống kê sản phẩm"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => xuatPDF(context),
          ),
        ],
      ),

      body: FutureBuilder<Map<String, int>>(
        future: thongKeSanPham(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          Map<String, int> data = snapshot.data!;
          int total = data.values.fold(0, (sum, item) => sum + item);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Biểu đồ thống kê sản phẩm",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartData(data, total),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: data.entries.map((entry) {
                      double percentage = (entry.value / total) * 100;
                      return ListTile(
                        leading: Icon(Icons.circle, color: _getColor(entry.key)),
                        title: Text(entry.key),
                        subtitle: Text("Số lượng: ${entry.value} (${percentage.toStringAsFixed(1)}%)"),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartData(Map<String, int> data, int total) {
    List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    int index = 0;

    return data.entries.map((entry) {
      final color = colors[index % colors.length];
      double percentage = (entry.value / total) * 100;
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColor(String key) {
    List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    int hash = key.hashCode;
    return colors[hash % colors.length];
  }
}
