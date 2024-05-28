import 'package:flutter/material.dart';

import 'package:music_test2/Common_Widgets/CommonNavbar.dart';
class Libraryscreen extends StatefulWidget {
  const Libraryscreen({super.key});

  @override
  State<Libraryscreen> createState() => _LibraryscreenState();
}

class _LibraryscreenState extends State<Libraryscreen> {
  int _currentIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library"),
      automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: CommonNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation based on index if needed
        },
      ),
    );
  }
}
