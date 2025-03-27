import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String selectedCategory = "Tất cả";
  TextEditingController priceController = TextEditingController();
  int? searchPrice;

  void _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sản phẩm đã được xóa!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa sản phẩm: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách sản phẩm", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/thongke-screen');
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/add-product-screen'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Đăng xuất", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Container(
        color: Colors.blue[100], // Thêm màu nền xanh nhạt
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedCategory,
                    items: ["Tất cả", "Sách", "Vở", "Bút chì"].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  Container(
                    width: 150,
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Nhập giá",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              priceController.clear();
                              searchPrice = null;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchPrice = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = (constraints.maxWidth / 200).floor();
                  return StreamBuilder<QuerySnapshot>(
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
                          "id": doc.id,
                          "idsanpham": data["idsanpham"] ?? "Không có ID",
                          "loaisp": data["loaisp"] ?? "Không xác định",
                          "gia": data["gia"] ?? 0,
                          "hinhanh": data["hinhanh"] ?? "https://via.placeholder.com/150",
                        };
                      }).where((product) {
                        if (product == null) return false;
                        if (selectedCategory != "Tất cả" && product["loaisp"] != selectedCategory) return false;
                        if (searchPrice != null) {
                          int productPrice = product["gia"];
                          if (productPrice < (searchPrice! - 20) || productPrice > (searchPrice! + 30)) return false;
                        }
                        return true;
                      }).toList();

                      return GridView.builder(
                        padding: EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount > 1 ? crossAxisCount : 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          var product = products[index]!;
                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    product["hinhanh"],
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Column(
                                    children: [
                                      Text("${product["loaisp"]} - ${product["gia"]} VNĐ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text("ID: ${product["idsanpham"]}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => Navigator.push(
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
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteProduct(product["id"]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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