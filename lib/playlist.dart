import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Playlist extends StatefulWidget {
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
             SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('user_playlist')
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
                                          
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
          ]
        )


      )
          ]
      )
  
    );
  }
}
