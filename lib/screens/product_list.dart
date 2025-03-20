import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_screen.dart'; // Import màn hình chỉnh sửa

class ProductListScreen extends StatelessWidget {
  void _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      print("Sản phẩm đã được xóa!");
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sản phẩm"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-product-screen');
            },
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Đăng xuất"),
          )
        ],

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Không có sản phẩm nào."));
          }

          var products = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>?;
            if (data == null) return null;

            return {
              "id": doc.id, // ID của document
              "idsanpham": data["idsanpham"] ?? "Không có ID",
              "loaisp": data["loaisp"] ?? "Không xác định",
              "gia": data["gia"] ?? 0,
              "hinhanh": data["hinhanh"] != null && data["hinhanh"].toString().isNotEmpty
                  ? data["hinhanh"]
                  :"https://upload.wikimedia.org/wikipedia/commons/4/40/MediaWiki-Purging-URL.png"
              ,
            };
          }).where((product) => product != null).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index]!;
              return ListTile(
                leading: Image.network(
                  product["hinhanh"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text("${product["loaisp"]} - ${product["gia"]} VNĐ"),
                subtitle: Text("ID sản phẩm: ${product["idsanpham"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProductScreen(
                              productId: product["id"],
                              idsanpham: product["idsanpham"],
                              loaisp: product["loaisp"],
                              gia: product["gia"],
                              hinhanh: product["hinhanh"],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product["id"]),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

}

