import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'home_tab.dart';
import 'my_bookings_tab.dart';
import '../profile_tab.dart';

class TravelerHome extends StatefulWidget {
  final User user;
  final VoidCallback logoutCallback;
  const TravelerHome(
      {super.key, required this.user, required this.logoutCallback});

  @override
  State<TravelerHome> createState() => _TravelerHomeState();
}

class _TravelerHomeState extends State<TravelerHome> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    HomeTab(),
    MyBookingsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_outlined), label: 'Pesanan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
