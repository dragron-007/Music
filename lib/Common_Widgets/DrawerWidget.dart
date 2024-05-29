import 'package:flutter/material.dart';
import 'package:music_test2/Screens/ProfileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_test2/Auth_service/SigninScreen.dart';
import 'package:music_test2/Screens/UploadSong.dart';
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              // Update the UI based on the drawer selection
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Profilescreen( ))); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout",style: TextStyle(fontWeight: FontWeight.bold),),
            onTap: () async {
              // Sign out the user
              try {
                await FirebaseAuth.instance.signOut();
                // Navigate to the sign-in screen or any other screen after sign-out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Signinscreen()),
                );
              } catch (e) {
                print("Error signing out: $e");
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.upload),
            title: Text("Upload Song"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadSong()));
            },
          ),
        ],
      ),
    );
  }
}
