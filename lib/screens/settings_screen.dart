import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/screens/game_mode_screen.dart';
import 'package:triple_t/screens/player_selection.dart';
import 'package:triple_t/widgets/custom_button.dart';

import '../widgets/exit_dialog.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  bool isSoundOn = true;
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
                    text: isSoundOn?'Sound Off':'Sound On',
                    onPressed: (){
                      isSoundOn
                      ?FlameAudio.bgm.pause()
                      :FlameAudio.bgm.play('music.ogg');

                      setState(() {
                        isSoundOn != isSoundOn;
                      });
                    },
                    bottomColor: const Color(0xFF0c3363),
                    darkColor: const Color(0xFF0a60c9),
                    lightColor: const Color(0xFF4a9bff),
                  ),
                  SizedBox(height: size.height/10),
                  GestureDetector(
                    onTap: (){
                      moveToNextScreen(context, const EntryScreen());
                    },
                    child: Image.asset('assets/images/back.png', height: 40),
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
