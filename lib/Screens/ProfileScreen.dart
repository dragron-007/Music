import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'EditProfile.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({Key? key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _streetAddressController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      _displayNameController.text = userDoc['displayName'];
      _phoneController.text = userDoc['phone'];
      _dobController.text = userDoc['dob'];
      _genderController.text = userDoc['gender'];
      _streetAddressController.text = userDoc['streetAddress'];
      _countryController.text = userDoc['country'];
      _photoUrl = userDoc['photoUrl'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(
                    displayName: _displayNameController.text,
                    phone: _phoneController.text,
                    dob: _dobController.text,
                    gender: _genderController.text,
                    streetAddress: _streetAddressController.text,
                    country: _countryController.text,
                    photoUrl: _photoUrl,
                  ),
                ),
              ).then((_) {
                _loadProfileData();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 75,
                backgroundImage:
                    _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                child: _photoUrl == null ? Icon(Icons.add_a_photo) : null,
              ),
              SizedBox(height: 20),
              _profileField("Display Name", _displayNameController),
              _profileField("Phone", _phoneController),
              _profileField("Date of Birth", _dobController),
              _profileField("Pronouns", _genderController),
              _profileField("Address", _streetAddressController),
              _profileField("Country", _countryController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Text(
            controller.text,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
