import 'package:flutter/material.dart';
import 'package:music_test2/model/playlist_provider.dart';
import 'package:music_test2/model/song.dart';
import 'package:provider/provider.dart';
import 'SongScreen.dart';
import 'package:music_test2/Common_Widgets/CommonNavbar.dart';
import 'package:music_test2/Common_Widgets/DrawerWidget.dart';
// import 'Common_Widgets/CommonNavbar.dart';
// import 'Common_Widgets/DrawerWidget.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _currentIndex = 0;
  late final PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.fetchSongs();  // Ensure songs are fetched on initialization
  }

  void goToSong(int songIndex) {
    playlistProvider.currentSongIndex = songIndex;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPage()),
    );
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
          final List<Song> playlist = value.playlist;
          if (value.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (playlist.isEmpty) {
            return Center(child: Text('No songs available'));
          }

          return ListView.builder(
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final Song song = playlist[index];
              return ListTile(
                title: Text(song.songName),
                subtitle: Text(song.artistName),
                onTap: () => goToSong(index),
              );
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
