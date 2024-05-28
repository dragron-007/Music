import 'package:flutter/material.dart';
import 'package:music_test2/Auth_service/SigninScreen.dart';
import 'package:music_test2/Themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:music_test2/model/playlist_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeProvider.themedata,
          debugShowCheckedModeBanner: false,
          home: Signinscreen(),
        );
      },
    );
  }
}
