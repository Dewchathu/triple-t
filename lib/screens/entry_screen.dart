import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/game_mode_screen.dart';
import 'package:triple_t/screens/player_selection.dart';
import 'package:triple_t/screens/settings_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';

import '../widgets/exit_dialog.dart';
import 'home_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({Key? key}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}


class _EntryScreenState extends State<EntryScreen> {
  bool isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('music.ogg');
  }

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
                  end: Alignment.bottomLeft
              )
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height/10),
                  CustomButton(
                    text: 'New Game',
                    onPressed: (){
                      moveToNextScreen(context, const PlayerSelection());
                    },
                    bottomColor: const Color(0xFF0c3363),
                    darkColor: const Color(0xFF0a60c9),
                    lightColor: const Color(0xFF4a9bff),
                  ),
                  SizedBox(height: size.height/9),
                  CustomButton(
                    text: 'Settings',
                    onPressed: (){
                      moveToNextScreen(context, const SettingsScreen());
                    },
                    bottomColor: const Color(0xFF0c3363),
                    darkColor: const Color(0xFF0a60c9),
                    lightColor: const Color(0xFF4a9bff),
                  ),
                  SizedBox(height: size.height/10),
                  GestureDetector(
                    onTap: () => _onBackPressed(context),
                    child: const Center(child: Text("Exit", style: TextStyle(fontSize: 20),)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitDialog.showExitConfirmationDialog(context) ?? false;
  }}
