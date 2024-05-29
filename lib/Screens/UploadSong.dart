import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;

class UploadSong extends StatefulWidget {
  const UploadSong({Key? key}) : super(key: key);

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _title = '';
  String _artist = '';
  String _album = '';
  int _duration = 0;
  String _genre = '';
  String _audioUrl = '';
  String _imageUrl = ''; // Optional

  File? _audioFile;

  // Function to handle form submission
  Future<void> _submitForm() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    // Upload song file to Firebase Storage
    try {
      if (_audioFile == null) {
        return;
      }

      // File upload task
      Reference ref = _storage.ref().child('songs/${Path.basename(_audioFile!.path!)}');
      UploadTask uploadTask = ref.putFile(_audioFile!);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      String audioUrl = await taskSnapshot.ref.getDownloadURL();

      // Save song metadata to Firestore or perform other actions with audioUrl

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Song uploaded successfully!')),
      );

      // Clear form after successful upload
      form.reset();
      _audioFile = null;
      setState(() {
        _audioUrl = audioUrl;
      });
    } catch (e) {
      print('Error uploading song: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload song. Please try again later.')),
      );
    }
  }

  // Function to pick audio file
  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'], // Adjust according to your file types
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Song"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Artist'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the artist';
                  }
                  return null;
                },
                onSaved: (value) => _artist = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Album'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the album';
                  }
                  return null;
                },
                onSaved: (value) => _album = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Duration (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  return null;
                },
                onSaved: (value) => _duration = int.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Genre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the genre';
                  }
                  return null;
                },
                onSaved: (value) => _genre = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickAudioFile,
                child: Text('Pick Audio File'),
              ),
              SizedBox(height: 10),
              if (_audioFile != null) Text('Selected Audio: ${Path.basename(_audioFile!.path!)}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Upload Song'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
