import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:music_room/presentation/HomePage/home_screen.dart';
import 'package:music_room/presentation/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignUpScreen({super.key});

  void signUp(BuildContext context) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup successful! Check your email to confirm.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signup failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 25),
          child: Column(
            children: [
              Image.asset("assets/music.jpg", height: 230),
              Text(
                "Register Here to listen\n        non stop music",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Password",
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.password, color: Colors.black),
                  ),
                  obscureText: false,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Get.to(() => RoomScreen());
                },
                child: Container(
                  width: 335,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "SignUp",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 35, top: 5),
                child: Row(
                  children: [
                    Text(
                      "Already have and account ?",
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => LoginScreen());
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
