import 'package:flutter/material.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/player_selection.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      moveToNextScreen(context, const PlayerSelection());
    });
    return const Scaffold(
      body:Center(
        child: Text("Welcome Triple-T", style: TextStyle(fontSize: 25),),
      ),
    );
  }
}
