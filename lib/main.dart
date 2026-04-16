import 'package:flutter/material.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/splashScreen.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/wishList.dart';
import 'package:medconnect_app/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WishlistProvider(),
      child: MaterialApp(
      routes: {
  '/home': (_) => const HomeScreen(),
  '/cart': (_) => const CartPage(),
  '/wishlist': (_) => const WishlistPage(),
},

      debugShowCheckedModeBanner: false,
      home: const MedConnectSplash(),
    ),
    );
    
    
    
    
  }
}


    



