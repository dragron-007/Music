import 'package:flutter/material.dart';
import 'package:music_test2/Themes/theme_provider.dart';
import 'package:provider/provider.dart';

class Settingsscreen extends StatefulWidget {
  const Settingsscreen({super.key});

  @override
  State<Settingsscreen> createState() => _SettingsscreenState();
}

class _SettingsscreenState extends State<Settingsscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"),
      ),
      body:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,0,8,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Dark Mode ",style: TextStyle( fontWeight: FontWeight.bold,fontSize: 18),),
                Switch(
                  value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
                  onChanged: (value) =>
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                ),

              ],
            ),
          ),
        ],
      ),

      // body: ,
    );
  }
}
