import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_test2/Screens/HomeScreen.dart';
import 'package:music_test2/Auth_service/SignupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool circular = false;

  SigninUserWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.background,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen()));
              },
              child: Text(
                "Skip",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ),
          _inputField("Enter your Email", false, _emailController, theme),
          _inputField("Enter your Password", true, _passwordController, theme),
          _button("Signin", SigninUserWithEmailAndPassword, theme),
          Divider(
            thickness: 1,
            color: theme.dividerColor,
            indent: 35,
            endIndent: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hello", style: textTheme.bodyLarge),
              Text("Hi", style: textTheme.bodyLarge),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: textTheme.bodyLarge),
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => Signupscreen()),
                        (route) => true,
                  );
                },
                child: Text(
                  "SignUp",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String hint, bool obText, TextEditingController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obText,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.hintColor),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(25),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.error),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _button(String text, void Function() onPressed, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width - 100,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: theme.textTheme.labelLarge?.color,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
