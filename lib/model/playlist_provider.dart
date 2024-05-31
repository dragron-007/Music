import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'song.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Song> _playlist = [];
  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;

  PlaylistProvider() {
    fetchSongs();
    listenToDuration();
  }

  Future<void> fetchSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('songs').get();
      _playlist = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Fetched song: ${data['title']} by ${data['artist']}');  // Debugging line
        return Song(
          songName: data['title'],
          artistName: data['artist'],
          audioPath: data['audioUrl'],  // Ensure this URL is accessible and correctly formatted
        );
      }).toList();
      print('Total fetched songs: ${_playlist.length}');  // Debugging line
    } catch (e) {
      print("Error fetching songs: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void play() async {
    if (_currentSongIndex == null) return;
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(path));  // Use UrlSource for URLs
    _isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
    notifyListeners();
  }

  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _playlist.length - 1) {
        currentSongIndex = _currentSongIndex! + 1;
      } else {
        currentSongIndex = 0;
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isLoading => _isLoading;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    notifyListeners();
  }
}
