
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
Future<void> saveFavToFirestore(
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

    await FirebaseFirestore.instance.collection('user_fav').doc(userId).collection('music').add({
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


