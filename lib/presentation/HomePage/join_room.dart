import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

Future<void> joinRoom() async {
  TextEditingController roomCodeController = TextEditingController();

  final String roomCode = roomCodeController.text.trim();
  final String uid = "getCurrentUserUIDHere";

  DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
      .collection('rooms')
      .doc(roomCode)
      .get();

  if (roomSnapshot.exists) {
    await FirebaseFirestore.instance.collection('rooms').doc(roomCode).update({
      'members': FieldValue.arrayUnion([uid]),
    });
    print("Joined room: $roomCode");
    // Navigate to room screen
  } else {
    print("Room does not exist");
    // Show alert
  }
}
