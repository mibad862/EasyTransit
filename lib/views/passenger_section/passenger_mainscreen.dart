import 'package:demo_project1/views/passenger_section/passenger_screen.dart';
import 'package:flutter/material.dart';

class PassengerMainScreen extends StatefulWidget {
  @override
  _PassengerMainScreenState createState() => _PassengerMainScreenState();
}

class _PassengerMainScreenState extends State<PassengerMainScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PassengerScreen(),
      ),
      // bottomNavigationBar: AnimatedBuilder(
      //   animation: _controller,
      //   builder: (context, child) {
      //     return BottomNavigationBar(
      //       items: const <BottomNavigationBarItem>[
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.home),
      //           label: 'Home',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.star),
      //           label: 'Reviews',
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.person),
      //           label: 'Profile',
      //         ),
      //       ],
      //       currentIndex: _selectedIndex,
      //       selectedItemColor: Colors.amberAccent,
      //       onTap: (index) {
      //         _onItemTapped(index);
      //         _controller.forward();
      //       },
      //     );
      //   },
      // ),
    );
  }

  // Widget _buildPage() {
  //   switch (_selectedIndex) {
  //     case 0:
  //       return PassengerScreen();
  //     case 1:
  //       return Text('Reviews Screen');
  //     case 2:
  //       return ProfileScreen(

  //       );
  //     default:
  //       return Container();
  //   }
  // }
}
