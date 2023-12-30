import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  late bool _isLoading;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _isLoading = false;
    _fetchUserData();
  }

  void _downloadMusic(String audioUrl) async {
  // You can use a package like `dio` to download the file
  // Make sure to add the `dio` dependency to your `pubspec.yaml` file
  // Example: dio: ^4.0.4

  // Get the directory where the file will be saved
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/music.mp3';

  // Create a dio instance
  final Dio dio = Dio();

  try {
    // Download the file
    await dio.download(audioUrl, filePath);

    // Show a success message or perform any other actions
    print('Music downloaded successfully to: $filePath');
  } catch (e) {
    // Handle download error
    print('Error downloading music: $e');
  }
}


  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      String username = userSnapshot['username'];
      String email = userSnapshot['email'];

      setState(() {
        _user.updateDisplayName(username);
        _user.updateEmail(email);
      });
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const SizedBox(height: 30),
_user.displayName != null
    ? CircleAvatar(
        radius: 50,
        backgroundColor: Color.fromRGBO(23, 147, 117, 1.0),
        backgroundImage: _user.photoURL != null
            ? NetworkImage(_user.photoURL!)
            : null,
        child: _user.photoURL == null
            ? Text(
                _user.displayName![0].toUpperCase(),
                style: const TextStyle(fontSize: 30),
              )
            : null,
      )
    : SizedBox(),
                      const SizedBox(height: 20),
                      Text(
                        'Name: ${_user.displayName ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Email: ${_user.email}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const TabBar(
                        tabs: [
                          Tab(text: 'Favourites', ),
                          Tab(text: 'Saved',),
                          

                        ],
                        unselectedLabelColor: Colors.white,
    labelColor: Color.fromRGBO(23, 147, 117, 1.0),
    indicator: BoxDecoration(
      color: Colors.transparent,
    ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                            child: Center(
                              child: Column(
                                children: [

                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('user_fav')
                                        .doc(_auth.currentUser!.uid)
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
                                        physics:
                                            NeverScrollableScrollPhysics(),
                                        itemCount: musicDocs.length,
                                        itemBuilder: (context, index) {
                                          var music = musicDocs[index].data()
                                              as Map<String, dynamic>;

                                          String name = music['name'] ?? '';
                                          String audio = music['audio'] ?? '';
                                          String image = music['image'] ?? '';
                                          String description = music[
                                                  'description'] ??
                                              '';

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
                                              // Navigate to the music player page
                                            },
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    // Add your logic for the favorite icon onPressed event
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.download,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    _downloadMusic(audio);
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
                            ),
                            SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                            child: Center(child: Column(children: [
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
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                          // Add your logic for the playlist_add icon onPressed event
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.download,
                                            color: Colors.white),
                                        onPressed: () {
                                          _downloadMusic(audio);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),


                            ],)),)
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
