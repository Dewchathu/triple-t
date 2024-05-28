import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import '../providers/sound_provider.dart';
import '../widgets/exit_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isSoundOn;

  @override
  void initState() {
    super.initState();
    isSoundOn = Provider.of<SoundProvider>(context, listen: false).isSoundOn;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
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
                  text: isSoundOn ? 'Sound Off' : 'Sound On',
                  onPressed: () {
                    final soundProvider = Provider.of<SoundProvider>(context, listen: false);
                    soundProvider.toggleSound();
                    setState(() {
                      isSoundOn = soundProvider.isSoundOn;
                    });
                    if (isSoundOn) {
                      FlameAudio.bgm.play('music.ogg');
                    } else {
                      FlameAudio.bgm.stop();
                    }
                  },
                  bottomColor: const Color(0xFF0c3363),
                  darkColor: const Color(0xFF0a60c9),
                  lightColor: const Color(0xFF4a9bff),
                ),
                SizedBox(height: size.height / 10),
                GestureDetector(
                  onTap: () {
                    moveToNextScreen(context, const EntryScreen());
                  },
                  child: Image.asset('assets/images/back.png', height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitDialog.showExitConfirmationDialog(context) ?? false;
  }
}
