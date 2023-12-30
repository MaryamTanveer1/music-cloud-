
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
  apiKey: "AIzaSyBq7s00GBOjoruP_jDB7t9jSOP6ppZ3_0o",
   authDomain: "musicapp2-9ba9d.firebaseapp.com",
   projectId: "musicapp2-9ba9d",
   storageBucket: "musicapp2-9ba9d.appspot.com",
   messagingSenderId: "583340792097",
   appId: "1:583340792097:web:9f4c9c845ee02e7e8c8660",
   measurementId: "G-7BMGW2927J"
    ),
  );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegistrationScreen(),
      // home: HomeScreen(username: 'username', auth: auth)
      // home: ProfileScreen(),
    );
  }
}


class MusicPlayerPage extends StatefulWidget {
  final String audio;
  final String image;
  final String name;
  final String discription;

  MusicPlayerPage({
    required this.audio,
     required this.image,
      required this.name,
       required this.discription,
  });

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  Future<void> saveMusicToFirestore(
    String name, String? audioUrl, String? imageUrl, String? description) async {
  try {
    if (_auth.currentUser == null) {
      print('User not authenticated.');
      return;
    }

    if (name == null || audioUrl == null || imageUrl == null || description == null) {
      print('One or more values are null:');
      print('Name: $name');
      print('Audio URL: $audioUrl');
      print('Image URL: $imageUrl');
      print('Description: $description');
      return;
    }

    String userId = _auth.currentUser!.uid;

    await FirebaseFirestore.instance.collection('user_playlist').doc(userId).collection('music').add({
      'name': name,
      'audio': audioUrl,  // Updated field name
      'image': imageUrl,  // Updated field name
      'description': description,
    });

    print('Music saved to Firestore.');
  } catch (e) {
    print('Error saving music to Firestore: $e');
  }
}

  Future<void> _setupAudioPlayer() async {
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stacktrace) {
      print("A stream error occurred: $e");
    });
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(widget.audio)),
        initialPosition: Duration.zero,
        preload: true,
      );
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  Widget _progressBar() {
    return StreamBuilder<Duration?>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        return ProgressBar(
          progress: snapshot.data ?? Duration.zero,
          buffered: _player.bufferedPosition,
          total: _player.duration ?? Duration.zero,
          onSeek: (duration) {
            _player.seek(duration);
          },
        progressBarColor: const Color.fromRGBO(23, 147, 117, 1.0), // Set your desired color here
        thumbColor: const Color.fromRGBO(23, 147, 117, 1.0),
        baseBarColor: Colors.white, // Set your desired color for the thumb
        timeLabelLocation: TimeLabelLocation.none,
        );
      },
    );
  }

    Widget _skipButton(IconData icon, Function() onPressed, bool isForward) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 32,
      color: const Color.fromARGB(255, 175, 175, 175),
      onPressed: () {
        // Calculate the seek position based on the current position
        final Duration currentPosition = _player.position ?? Duration.zero;
        final Duration newPosition = isForward
            ? currentPosition + const Duration(seconds: 10)
            : currentPosition - const Duration(seconds: 10);

        // Seek to the new position
        _player.seek(newPosition);
      },
    );
  }

  Widget _playbackControlButton() {
    return StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final processingState = snapshot.data?.processingState;
          final playing = snapshot.data?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 64,
              height: 64,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
  return IconButton(
    icon: const Icon(Icons.play_circle_outline),
    iconSize: 64,
    color: const Color.fromARGB(255, 175, 175, 175),
    onPressed: () {
      // Add your additional functionality here
      _player.play();
      saveMusicToFirestore(widget.name, widget.audio, widget.image, widget.discription);
    },
  );
}
           else if (processingState != ProcessingState.completed) {
            return IconButton(
              icon: const Icon(Icons.pause_circle_outline),
              iconSize: 64,
              color: const Color.fromARGB(255, 175, 175, 175),
              onPressed: _player.pause,
            );
          } else {
            return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64,
                color: const Color.fromARGB(255, 175, 175, 175),
                onPressed: () => _player.seek(Duration.zero));
          }
        });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: const Text('MusicCloud', style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 255, 255, 1))),
          backgroundColor: Colors.transparent,
          elevation: 0,
      ),
      body: Stack(
        children:[
          Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.PNG'),
                    fit: BoxFit.cover,
                  ),
                ),
                ),
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(
                widget.image,
                height: 360.0,
                width: 290.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10.0),
              Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
              Text(
            widget.discription,
            style: const TextStyle(fontSize: 15, color: Color.fromARGB(255, 184, 184, 184)),
          ),
          const SizedBox(height: 10.0),
                _progressBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _skipButton(Icons.skip_previous_outlined, () {
                        // Handle skip to previous logic
                      }, false),
                    _playbackControlButton(),
                    _skipButton(Icons.skip_next_outlined, () {
                        // Handle skip to next logic
                      }, true),
                  ],
                ),

              ],
            ),
          ),
        ),] 
      ),
    );
  }
}

class MusicBox extends StatefulWidget {
  final String name;
  final String image;
  final String audio;
  final String discription;

  MusicBox({
    required this.name,
    required this.image,
    required this.audio,
    required this.discription,
  });

  @override
  _MusicBoxState createState() => _MusicBoxState();
}

class _MusicBoxState extends State<MusicBox> {
// Future<void> saveMusicToFirestore(String name, String audioUrl, String imageUrl, String description) async {
//   try {
//     await FirebaseFirestore.instance.collection('music').add({
//       'name': name,
//       'audioUrl': audioUrl,
//       'imageUrl': imageUrl,
//       'description': description,
//     });
//     print('Music saved to Firestore.');
//   } catch (e) {
//     print('Error saving music to Firestore: $e');
//   }
// }

Future<void> saveMusicToFirestore(
    String name, String? audioUrl, String? imageUrl, String? description) async {
  try {
    if (_auth.currentUser == null) {
      print('User not authenticated.');
      return;
    }

    if (name == null || audioUrl == null || imageUrl == null || description == null) {
      print('One or more values are null:');
      print('Name: $name');
      print('Audio URL: $audioUrl');
      print('Image URL: $imageUrl');
      print('Description: $description');
      return;
    }

    String userId = _auth.currentUser!.uid;

    await FirebaseFirestore.instance.collection('user_music').doc(userId).collection('music').add({
      'name': name,
      'audio': audioUrl,  // Updated field name
      'image': imageUrl,  // Updated field name
      'description': description,
    });

    print('Music saved to Firestore.');
  } catch (e) {
    print('Error saving music to Firestore: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
             if (widget.image.isNotEmpty)
             ClipRRect(
  borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
  child:Image.network(
                  widget.image,
                  height: 190.0,
                  width: 170.0,
                  fit: BoxFit.cover,
                )
             )
              // Use a placeholder icon or image for newly uploaded music
              else
                Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey, width: 1.0, ),
        ),
        child: const Icon(
          Icons.music_note, // Use any desired icon
          size: 100.0,
          color: Colors.grey, // Adjust color as needed
        ),
      ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.discription,
            style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 184, 184, 184)),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              IconButton(
                alignment: Alignment.topRight,
                icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerPage(
                        audio: widget.audio,
                        image: widget.image,
                        name: widget.name,
                        discription: widget.discription,
                      ),
                    ),
                  );
                },     
              ),
              IconButton(
                alignment: Alignment.topRight,
                icon: const Icon(Icons.playlist_add, color: Colors.white),
                 onPressed: () async {
    await saveMusicToFirestore(widget.name, widget.audio, widget.image, widget.discription);
  },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

