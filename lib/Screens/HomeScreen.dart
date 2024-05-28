import 'package:flutter/material.dart';
import 'package:music_test2/Screens/SettingsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'SongScreen.dart';
import 'package:music_test2/model/playlist_provider.dart';
import 'package:music_test2/model/song.dart';
import 'package:provider/provider.dart';
import 'package:music_test2/Common_Widgets/CommonNavbar.dart';
import 'package:music_test2/Common_Widgets/DrawerWidget.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();

    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goTosong(int songIndex) {
    playlistProvider.currentSongIndex = songIndex;

    Navigator.push(context, MaterialPageRoute(builder: (context) => SongPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Musically Yours'),
      ),
      drawer: DrawerWidget(),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          // get the playlist
          final List<Song> playlist = value.playlist;

          // return list view UI
          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              // get individual song
              final Song song = playlist[index];
              // return list tile UI
              return ListTile(
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                // leading: Image.asset(song.albumArtImagePath),
                onTap: () => goTosong(index),
              ); // ListTile
            },
          );
        },
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
