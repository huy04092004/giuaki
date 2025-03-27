import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _loaiController = TextEditingController();
  final TextEditingController _giaController = TextEditingController();
  final TextEditingController _hinhanhController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _hinhanhController.clear();
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = "products/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải ảnh: $e")),
      );
      return null;
    }
  }

  void _addProduct() async {
    String id = _idController.text.trim();
    String loai = _loaiController.text.trim();
    String gia = _giaController.text.trim();
    String hinhanh = _hinhanhController.text.trim();

    if (id.isEmpty || loai.isEmpty || gia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    int? giaSanPham = int.tryParse(gia);
    if (giaSanPham == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giá sản phẩm phải là số hợp lệ")),
      );
      return;
    }

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
    } else if (hinhanh.isNotEmpty) {
      imageUrl = hinhanh;
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng chọn ảnh hoặc nhập URL")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'idsanpham': id,
        'loaisp': loai,
        'gia': giaSanPham,
        'hinhanh': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sản phẩm đã được thêm!")),
      );

      _idController.clear();
      _loaiController.clear();
      _giaController.clear();
      _hinhanhController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi thêm sản phẩm: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm Sản Phẩm"),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.transparent, // Đảm bảo không đè lên màu nền của Container
      body: Container(
        color: Colors.blue.shade300, // Màu nền cho toàn bộ trang
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_idController, Icons.confirmation_number, "ID Sản Phẩm"),
                    _buildTextField(_loaiController, Icons.category, "Loại Sản Phẩm"),
                    _buildTextField(_giaController, Icons.attach_money, "Giá", isNumber: true),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text("Chọn ảnh từ thư viện"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, height: 150),
                      ),
                    _buildTextField(_hinhanhController, Icons.link, "Hoặc nhập URL ảnh"),
                    if (_hinhanhController.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _hinhanhController.text,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return Text("URL ảnh không hợp lệ");
                          },
                        ),
                      ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addProduct,
                        icon: Icon(Icons.add_circle),
                        label: Text("Thêm Sản Phẩm"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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


  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
