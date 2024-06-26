import 'package:flutter/material.dart';
import 'SigninScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({Key? key}) : super(key: key);

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _circular = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _createUserWithEmailAndPassword() async {
    setState(() {
      _circular = true;
    });

    // Validate inputs
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _fullNameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      setState(() {
        _circular = false;
        _errorMessage = 'All fields are required';
      });
      _showSnackbar(_errorMessage);
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        .hasMatch(_emailController.text.trim())) {
      setState(() {
        _circular = false;
        _errorMessage = 'Please enter a valid email';
      });
      _showSnackbar(_errorMessage);
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      setState(() {
        _circular = false;
        _errorMessage = 'Password should be at least 6 characters';
      });
      _showSnackbar(_errorMessage);
      return;
    }

    try {
      bool usernameExists = await _checkIfUsernameExists(_usernameController.text.trim());
      if (usernameExists) {
        setState(() {
          _circular = false;
        });
        _showSnackbar('The username is already taken. Please choose another one.');
        return;
      }

      final UserCredential credential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'createdOn': FieldValue.serverTimestamp(),
      });

      // Navigate to the sign-in screen after successful account creation
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Signinscreen()));
    } on FirebaseAuthException catch (e) {
      // Handle different sign-up errors
      if (e.code == 'weak-password') {
        _showSnackbar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showSnackbar('The account already exists for that email.');
      } else {
        _showSnackbar('An error occurred. Please try again.');
      }
    } catch (e) {
      print(e);
      _showSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _circular = false;
      });
    }
  }

  Future<bool> _checkIfUsernameExists(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Signup Screen"),
        backgroundColor: theme.colorScheme.background,
      ),
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              inputField("Enter Email", false, _emailController, theme),
              inputField("Enter Full Name", false, _fullNameController, theme),
              inputField("Enter Username", false, _usernameController, theme),
              inputField("Enter Password", true, _passwordController, theme),
              _button("Signup", _createUserWithEmailAndPassword, theme),
              if (_circular)
                CircularProgressIndicator(),
            ],
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
                color: theme.colorScheme.onPrimary,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget inputField(String hint, bool isPassword,
      TextEditingController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: theme.hintColor),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            keyboardType: isPassword
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
          ),
        ),
      ),
    );
  }
}
