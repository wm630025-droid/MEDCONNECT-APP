import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/massegesScreen.dart';
import 'package:medconnect_app/equipmentListScreen.dart';
import 'package:medconnect_app/doctorProfile.dart';


import 'homeScreen.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // هنا كل الصفحات اللي هتظهر داخل الـ body
  final List<Widget> _pages = [
    const HomeScreen(),
    const CartPage(),
     MessagesScreen(),
     EquipmentListsScreen(),
     // DoctorProfilePage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====== BODY ======
      body: _pages[_selectedIndex],

      // ====== BOTTOM NAVIGATION BAR ثابت ======
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0A69C3),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.playlist_add), label: "Equipment"),
        ],
      ),
    );
  }
}