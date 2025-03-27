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
      appBar: AppBar(
        title: Text("Chỉnh sửa sản phẩm", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField("ID Sản Phẩm", _idController, Icons.qr_code),
                    SizedBox(height: 10),
                    _buildTextField("Loại Sản Phẩm", _loaiController, Icons.category),
                    SizedBox(height: 10),
                    _buildTextField("Giá", _giaController, Icons.attach_money, isNumber: true),
                    SizedBox(height: 10),
                    _buildTextField("URL Hình Ảnh", _hinhanhController, Icons.image),
                    SizedBox(height: 10),

                    // Hiển thị ảnh từ URL
                    if (_hinhanhController.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _hinhanhController.text,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text("URL ảnh không hợp lệ", style: TextStyle(color: Colors.red));
                          },
                        ),
                      ),

                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _updateProduct,
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text("Lưu thay đổi", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tạo ô nhập liệu đẹp hơn
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
