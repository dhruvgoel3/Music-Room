import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_room/presentation/HomePage/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // void initState() {
  //   super.initState();
  //
  //   Future.delayed(Duration(seconds: 3), () {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => RoomScreen()),
  //     );
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding:  EdgeInsets.only(bottom: 50),
              child: CircleAvatar(
                radius: 150,
                backgroundColor: Colors.black,
                child: Icon(CupertinoIcons.double_music_note, color: Colors.green,size: 150,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
