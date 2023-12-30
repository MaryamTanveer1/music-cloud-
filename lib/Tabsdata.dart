import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app3/playlist.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:typed_data';
import 'fav.dart';
import 'profile.dart';


// Assuming the MusicBox and MusicPlayerPage classes are defined correctly
class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isFavorite = false;
  final List<Map<String, String>> musicData = [
    // Your music data here
    {
      'name': 'Faded',
      'image': 'assets/c1.PNG',
      'audio': 'assets/song1.mp3',
      'discription': 'Annie Kolden, Brad Pit'
    },
    {
      'name': 'Let me down slowly',
      'image': 'assets/c6.PNG',
      'audio':
          'assets/Let-Me-Down-Slowly---Alec-Benjamin-mp3(musicdownload.cc).mp3',
      'discription': 'Alec-Benjamin'
    },
    {
      'name': 'Epic cinematic',
      'image': 'assets/c2.PNG',
      'audio': 'assets/song2.mp3',
      'discription': 'Selena, Brad Pit'
    },
    // Add more songs as needed
  ];
  final List<Map<String, String>> musicData2 = [
    // Your music data here
    {
      'name': 'Stay',
      'image': 'assets/c4.PNG',
      'audio': 'assets/Stay(PaglaSongs).mp3',
      'discription': 'Justin Bieber, Kid laroi'
    },
    {
      'name': 'Stitches',
      'image': 'assets/c3.PNG',
      'audio': 'assets/Shawn_Mendes_-_Stitches.mp3',
      'discription': 'Shawn_Mendes'
    },
    {
      'name': 'Cradle of Soul',
      'image': 'assets/c5.PNG',
      'audio': 'assets/the-cradle-of-your-soul-15700.mp3',
      'discription': 'Albert Kim, Selena'
    },

    // Add more songs as needed
  ];

  Future<void> uploadAudioFile(
      List<Uint8List> bytesList, String fileName, String description) async {
    try {
      // Upload audio file to Firebase Storage
      firebase_storage.Reference audioRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('uploads')
          .child(fileName);

      Uint8List audioBytes = bytesList[0];

      await audioRef.putData(
        audioBytes,
        firebase_storage.SettableMetadata(
          contentType: 'audio/mpeg',
        ),
      );

      String audioDownloadURL = await audioRef.getDownloadURL();

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('musicupload').add({
        'name': fileName,
        'audio': audioDownloadURL,
        'description': description,
        'username': widget.username,
      });

      print('Audio file uploaded successfully. URL: $audioDownloadURL');
    } catch (e) {
      print('Error uploading audio file to Firebase Storage: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context); // Go back to the previous screen after logout
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: const Text('MusicCloud',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(255, 255, 255, 1))),
          backgroundColor: Colors.transparent,
          elevation: 0,
                  actions: [
          PopupMenuButton(
            icon: Icon(
    Icons.more_vert,
    color: Colors.white, // Set the color of the icon
  ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.PNG'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50.0),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Trending on MusicCloud',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(23, 147, 117, 1.0))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: musicData.map((music) {
                                return MusicBox(
                                  name: music['name']!,
                                  image: music['image']!,
                                  audio: music['audio']!,
                                  discription: music['discription']!,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Party',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(23, 147, 117, 1.0))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: musicData2.map((music) {
                                return MusicBox(
                                  name: music['name']!,
                                  image: music['image']!,
                                  audio: music['audio']!,
                                  discription: music['discription']!,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Recents',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(23, 147, 117, 1.0),
                            ),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('musicupload')
      .where('username', isEqualTo: widget.username)
      .snapshots(),
  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text('Loading...');
    }

    List<QueryDocumentSnapshot> uploadedMusicDocs = snapshot.data!.docs;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: uploadedMusicDocs.map((music) {
          var musicData = music.data() as Map<String, dynamic>;

          String name = musicData['name'] ?? '';
          String audio = musicData['audio'] ?? '';
          String image = musicData['image'] ?? '';
          String description = musicData['description'] ?? '';

          return MusicBox(
            name: name,
            image: image,
            audio: audio,
            discription: description,
          );
        }).toList(),
      ),
    );
  },
),

                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.cloud_upload,
                          color: Color.fromARGB(255, 74, 73, 73),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'mp3'
                              ], // Only allow mp3 files for audio
                            );

                            if (result != null && result.files.isNotEmpty) {
                              String audioFileName =
                                  result.files.first.name ?? '';
                              List<Uint8List> fileBytesList = result.files
                                  .map((file) => file.bytes!)
                                  .toList();

                              String description =
                                  'Your music description goes here';

                              if (audioFileName.isNotEmpty) {
                                // Upload the audio file to Firebase Storage, and save metadata to Firestore
                                await uploadAudioFile(
                                    fileBytesList, audioFileName, description);
                              }
                            } else {
                              // User canceled the file picking or no files selected
                            }
                          } catch (e) {
                            print('Error picking files: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(23, 147, 117, 1.0),
                        ),
                        child: const Text('Upload Audio'),
                      ),

                      // ... Remaining code ...
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Library',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('user_music')
                              .doc(_auth.currentUser!
                                  .uid) // Use the current user's ID
                              .collection('music')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading...');
                            }

                            List<QueryDocumentSnapshot> musicDocs =
                                snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: musicDocs.length,
                              itemBuilder: (context, index) {
                                var music = musicDocs[index].data()
                                    as Map<String, dynamic>;

                                String name = music['name'] ?? '';
                                String audio = music['audio'] ?? '';
                                String image = music['image'] ?? '';
                                String description = music['description'] ??
                                    ''; // Corrected the field name

                                return ListTile(
                                  leading: Image.network(
                                    image,
                                    height: 50.0,
                                    width: 50.0,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                          255, 130, 130, 130),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MusicPlayerPage(
                                          name: name,
                                          image: image,
                                          audio: audio,
                                          discription: description,
                                        ),
                                      ),
                                    );
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            isFavorite =
                                                !isFavorite; // Toggle the state
                                          });

                                          if (isFavorite) {
                                            // Add your logic for the favorite icon onPressed event
                                            await saveFavToFirestore(name,
                                                audio, image, description);
                                          } else {
                                            // Add your logic for the unfavorite icon onPressed event
                                            // For example, remove from favorites
                                            // await removeFromFavorites(name);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.download,
                                            color: Colors.white),
                                        onPressed: () {
                                          // Add your logic for the playlist_add icon onPressed event
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Playlist(),
                  ProfileScreen(),
                      
                ],
              ),
            ),
          ],
        ),
bottomNavigationBar: Container(
  color: Colors.black,
  child: TabBar(
    tabs: [
      Tab(
        icon: Icon(Icons.home),
      ),
      Tab(icon: Icon(Icons.cloud_upload)),
      Tab(icon: Icon(Icons.library_music)),
      Tab(icon: Icon(Icons.playlist_play)),
      Tab(icon: Icon(Icons.person)),

    ],
    unselectedLabelColor: Colors.grey,
    labelColor: Color.fromRGBO(23, 147, 117, 1.0),
    indicator: BoxDecoration(
      color: Colors.transparent,
    ),

  ),
),

      ),
    );
  }
}
