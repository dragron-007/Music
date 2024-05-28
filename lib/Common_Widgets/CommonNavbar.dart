import 'package:flutter/material.dart';
import 'package:music_test2/Screens/HomeScreen.dart';
import 'package:music_test2/Screens/LibraryScreen.dart';
import 'package:music_test2/Screens/SearchScreen.dart';

class CommonNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  CommonNavBar({required this.currentIndex, required this.onTap, });
  final List<Widget> _pages = [
    Homescreen(),
    Searchscreen(),
    Libraryscreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(

      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      elevation: 5,
      backgroundColor: Colors.transparent,
      onTap: (index) {
        if (index < _pages.length) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => _pages[index],
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } else {
          onTap(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.black87,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: Colors.black87,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.my_library_music_rounded),
          label: 'Library',
          backgroundColor: Colors.blueGrey[900],
        ),
      ],

    );
  }
}
