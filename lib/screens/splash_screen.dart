import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/screens/player_selection.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      moveToNextScreen(context, const EntryScreen());
    });
    return Scaffold(
      body:Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft
          )
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text("Welcome Triple-T",
                style: GoogleFonts.lemon(
                fontSize: 30,
                color: Colors.white,
              ),),
            ),
          ],
        ),
      )
    );
  }
}
