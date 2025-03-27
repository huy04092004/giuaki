import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:magic_8_ball_app/screens/thongke_screen.dart';

import 'screens/login_screen.dart';  // Đảm bảo có dòng này
import 'screens/register_screen.dart';
import 'screens/product_list.dart';
import 'screens/add_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        // apiKey: "AIzaSyDpt421ZI1Rtg5A3Lu2hrVqyDk4zdDIMaY",
        // authDomain: "flutterfirebase-22160.firebaseapp.com",
        // projectId: "flutterfirebase-22160",
        // storageBucket: "flutterfirebase-22160.appspot.com",
        // messagingSenderId: "579104989154",
        // appId: "1:579104989154:web:218775b890a9898c4763bb",
        // measurementId: "G-R0KX6P60MK",
          apiKey: "AIzaSyD9s1ApyA5enTOzsV6DABUaZ0F8vyEnJ68",
          authDomain: "huyhuy-2aec9.firebaseapp.com",
          projectId: "huyhuy-2aec9",
          storageBucket: "huyhuy-2aec9.firebasestorage.app",
          messagingSenderId: "679728833340",
          appId: "1:679728833340:web:d7738a23a917a61ad17439",
          measurementId: "G-B2GXJD949Q"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Mở app lên vào màn hình đăng nhập
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => ProductListScreen(),
        '/thongke-screen': (context) => ThongKeScreen(),

        '/add-product-screen': (context) => AddProductScreen(),
      },
    );
  }
}
