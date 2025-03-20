import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final String idsanpham;
  final String loaisp;
  final int gia;
  final String hinhanh;

  EditProductScreen({
    required this.productId,
    required this.idsanpham,
    required this.loaisp,
    required this.gia,
    required this.hinhanh,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _idController;
  late TextEditingController _loaiController;
  late TextEditingController _giaController;
  late TextEditingController _hinhanhController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.idsanpham);
    _loaiController = TextEditingController(text: widget.loaisp);
    _giaController = TextEditingController(text: widget.gia.toString());
    _hinhanhController = TextEditingController(text: widget.hinhanh);
  }

  void _updateProduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'idsanpham': _idController.text.trim(),
        'loaisp': _loaiController.text.trim(),
        'gia': int.parse(_giaController.text.trim()),
        'hinhanh': _hinhanhController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sản phẩm đã được cập nhật!")),
      );

      Navigator.pop(context); // Quay lại danh sách sản phẩm
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật sản phẩm: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa sản phẩm")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "ID Sản Phẩm"),
            ),
            TextField(
              controller: _loaiController,
              decoration: InputDecoration(labelText: "Loại Sản Phẩm"),
            ),
            TextField(
              controller: _giaController,
              decoration: InputDecoration(labelText: "Giá"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _hinhanhController,
              decoration: InputDecoration(labelText: "URL Hình Ảnh"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text("Lưu thay đổi"),
            ),
          ],
        ),
      ),
    );
  }
}
