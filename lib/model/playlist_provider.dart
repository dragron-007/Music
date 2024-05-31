import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'song.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [
    // Song(
    //   songName: "Desi Kalakaar",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Desi Kalakaar.mp3',
    // ),
    // Song(
    //   songName: "All Black",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/All Black.mp3',
    // ),
    // Song(
    //   songName: "Chandigarh Ka Chokra",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Chandigarh Ka Chokra.mp3',
    // ),
    // Song(
    //   songName: "Expert Jatt",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Expert Jatt.mp3',
    // ),
    // Song(
    //   songName: "Love Dose",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Love Dose.mp3',
    // ),
    // Song(
    //   songName: "Proper Patola",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Proper Patola.mp3',
    // ),
    // Song(
    //   songName: "Horn Bloww",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Hornn Blow.mp3',
    // ),
    // Song(
    //   songName: "Admiring You",
    //   artistName: 'Honey Singh',
    //   audioPath: 'music/Admiring You.mp3',
    // ),
  ];

  int? _currentSongIndex;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  PlaylistProvider() {
    listenToDuration();
  }

  bool _isPlaying = false;

  void play() async {
    if (_currentSongIndex == null) return;
    final String path = _playlist[_currentSongIndex!].audioPath;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
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

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }
    notifyListeners();
  }
}
