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
  final TextEditingController _hinhanhController = TextEditingController(); // Nhập URL ảnh

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  /// Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _hinhanhController.clear(); // Xóa URL nếu đã chọn ảnh
      });
    }
  }

  /// Upload ảnh lên Firebase Storage và lấy URL
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

  /// Thêm sản phẩm vào Firestore
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
      imageUrl = hinhanh; // Dùng URL nhập vào nếu không chọn ảnh
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
      appBar: AppBar(title: Text("Thêm Sản Phẩm")),
      body: SingleChildScrollView(
        child: Padding(
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
              SizedBox(height: 10),

              // Nút chọn ảnh từ thư viện
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Chọn ảnh từ thư viện"),
              ),

              // Hiển thị ảnh đã chọn
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                  ),
                ),

              // Nhập URL ảnh thủ công
              TextField(
                controller: _hinhanhController,
                decoration: InputDecoration(labelText: "Hoặc nhập URL ảnh"),
                onChanged: (value) {
                  setState(() {
                    _selectedImage = null; // Nếu nhập URL thì bỏ ảnh đã chọn
                  });
                },
              ),

              // Hiển thị ảnh từ URL
              if (_hinhanhController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    _hinhanhController.text,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Text("URL ảnh không hợp lệ");
                    },
                  ),
                ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text("Thêm Sản Phẩm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
