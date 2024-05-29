import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Add this import for date formatting

class EditProfile extends StatefulWidget {
  final String displayName;
  final String phone;
  final String dob;
  final String gender;
  final String streetAddress;
  final String country;
  final String? photoUrl;

  const EditProfile({
    Key? key,
    required this.displayName,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.streetAddress,
    required this.country,
    this.photoUrl,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _streetAddressController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  bool _loading = false;
  final User? user = FirebaseAuth.instance.currentUser;
  File? _image;
  String? _photoUrl;
  String? _selectedPronoun;
  final List<String> _pronouns = ['he/him', 'she/her', 'they/them'];

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.displayName;
    _phoneController.text = widget.phone;
    _dobController.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.dob)); // Format the initial date
    _selectedPronoun = widget.gender;
    _streetAddressController.text = widget.streetAddress;
    _countryController.text = widget.country;
    _photoUrl = widget.photoUrl;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_images/${user!.uid}.jpg');
      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      String? photoUrl = await _uploadImage();
      if (photoUrl == null && _photoUrl != null) {
        photoUrl = _photoUrl;
      }
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'displayName': _displayNameController.text.trim(),
        'photoUrl': photoUrl,
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'gender': _selectedPronoun,
        'streetAddress': _streetAddressController.text.trim(),
        'country': _countryController.text.trim(),
      });

      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile.')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(_dobController.text);
      } catch (e) {
        print('Error parsing initial date: $e');
      }
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Format selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: _image == null && _photoUrl == null
                      ? Icon(Icons.add_a_photo)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _editableField("Display Name", _displayNameController),
              _editableField("Phone", _phoneController),
              _editableField("Date of Birth", _dobController, readOnly: true, onTap: () => _selectDate(context)),
              _dropdownField("Pronouns", _selectedPronoun, _pronouns, (value) {
                setState(() {
                  _selectedPronoun = value;
                });
              }),
              _editableField("Address", _streetAddressController),
              _editableField("Country", _countryController),
              SizedBox(height: 20),
              _button("Update Profile", _updateUserProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller, {bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String text, void Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: _loading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(text),
      ),
    );
  }
}
