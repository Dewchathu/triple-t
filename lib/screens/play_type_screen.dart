import 'package:flutter/material.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/screens/player_selection.dart';

import '../actions/moveto_next_screen.dart';
import '../widgets/custom_button.dart';

class PlayTypeScreen extends StatefulWidget {
  const PlayTypeScreen({Key? key}) : super(key: key);

  @override
  State<PlayTypeScreen> createState() => _PlayTypeScreenState();
}

class _PlayTypeScreenState extends State<PlayTypeScreen> {
  String playType = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Single Play',
                  onPressed: () {
                    moveToNextScreen(context, const PlayerSelection(playType: 'single'));
                  },
                  bottomColor: const Color(0xFF0c3363),
                  darkColor: const Color(0xFF0a60c9),
                  lightColor: const Color(0xFF4a9bff),
                ),
                SizedBox(height: size.height / 9),
                CustomButton(
                  text: 'Play With Friend',
                  onPressed: () {
                    moveToNextScreen(context, const PlayerSelection(playType: 'double'));
                  },
                  bottomColor: const Color(0xFF0c3363),
                  darkColor: const Color(0xFF0a60c9),
                  lightColor: const Color(0xFF4a9bff),
                ),
                const SizedBox(height: 80),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      moveToNextScreen(context, const EntryScreen());
                    },
                    child: Image.asset('assets/images/back.png', height: 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
