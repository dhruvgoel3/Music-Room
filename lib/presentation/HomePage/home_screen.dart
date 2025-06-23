import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_room/presentation/MusicRoomPage/music_room_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController roomCodeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "uid123"; // Replace with actual user ID logic

  Future<void> createRoom(BuildContext context) async {
    String roomCode = roomCodeController.text.trim().toUpperCase();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a room code')));
      return;
    }

    DocumentSnapshot doc = await _firestore
        .collection("rooms")
        .doc(roomCode)
        .get();

    if (doc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Room already exists')));
    } else {
      await _firestore.collection("rooms").doc(roomCode).set({
        "createdBy": userId,
        "createdAt": Timestamp.now(),
        "members": [userId],
        "audioUrl": "",
        "playback": {
          "isPlaying": false,
          "position": 0,
          "lastUpdatedBy": userId,
        },
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Room created successfully')));

      // ✅ Navigate to music room after room creation
      Get.to(
        () => MusicRoomScreen(
          roomCode: roomCode,
          userId: userId,
          isCreator: true,
        ),
      );
    }
  }

  Future<void> joinRoom(BuildContext context) async {
    String roomCode = roomCodeController.text.trim().toUpperCase();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a room code')));
      return;
    }

    DocumentSnapshot doc = await _firestore
        .collection("rooms")
        .doc(roomCode)
        .get();

    if (doc.exists) {
      await _firestore.collection("rooms").doc(roomCode).update({
        "members": FieldValue.arrayUnion([userId]),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Joined room successfully')));

      // ✅ Navigate to music room after joining
      Get.to(
        () => MusicRoomScreen(
          roomCode: roomCode,
          userId: userId,
          isCreator: false,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Room not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Create / Join a Music Room',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(height: 50),

                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  child: Icon(
                    CupertinoIcons.music_note_list,
                    color: Colors.green,
                    size: 70,
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  "Enter a existing code to join a Room",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "OR",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                Text(
                  "Enter a six digit code & \n    create a new room",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: roomCodeController,
                      decoration: InputDecoration(
                        hintText: "Enter Room Code",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        prefixIcon: Icon(Icons.password, color: Colors.black),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => createRoom(context),
                  child: Text("Create Room"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => joinRoom(context),
                  child: Text("Join Room"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
