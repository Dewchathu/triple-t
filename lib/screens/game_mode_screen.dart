import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/player_selection.dart';
import 'package:triple_t/screens/single_player_screen.dart' as single;
import 'package:triple_t/screens/two_player_screen.dart' as doubal;
import 'package:triple_t/screens/two_player_screen.dart';
import 'package:triple_t/screens/two_player_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';

class GameModeScreen extends StatefulWidget {
  final String playType;
  final String playerOne;
  final String playerTwo;
  const GameModeScreen({Key? key, required this.playerOne, required this.playerTwo, required this.playType}) : super(key: key);

  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Player 1', style: GoogleFonts.lemon(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(widget.playerOne, style: GoogleFonts.lemon(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Player 2', style: GoogleFonts.lemon(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        widget.playType == 'single'
                            ? Text('Triple T', style: GoogleFonts.lemon(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold))
                            : Text(widget.playerTwo, style: GoogleFonts.lemon(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: size.height / 10),
                CustomButton(
                  text: '3x3',
                  onPressed: () {
                    final difficultyS = single.Difficulty(name: "3x3", itemCount: 9, crossAxisCount: 3, playerOne: widget.playerOne, playerTwo: 'Triple T');
                    final difficultyD = doubal.Difficulty(name: "3x3", itemCount: 9, crossAxisCount: 3, playerOne: widget.playerOne, playerTwo: widget.playerTwo);
                    widget.playType == 'double'
                        ? moveToNextScreen(context, doubal.TwoPlayerScreen(difficulty: difficultyD))
                        : moveToNextScreen(context, single.SinglePlayerScreen(difficulty: difficultyS));
                  },
                  bottomColor: const Color(0xFFCD8F0A),
                  darkColor: const Color(0xFFF19F03),
                  lightColor: const Color(0xFFFFEC48),
                ),
                SizedBox(height: size.height / 9),
                CustomButton(
                  text: '4x4',
                  onPressed: () {
                    final difficultyS = single.Difficulty(name: "4x4", itemCount: 16, crossAxisCount: 4, playerOne: widget.playerOne, playerTwo: 'Triple T');
                    final difficultyD = doubal.Difficulty(name: "4x4", itemCount: 16, crossAxisCount: 4, playerOne: widget.playerOne, playerTwo: widget.playerTwo);
                    widget.playType == 'double'
                        ? moveToNextScreen(context, doubal.TwoPlayerScreen(difficulty: difficultyD))
                        : moveToNextScreen(context, single.SinglePlayerScreen(difficulty: difficultyS));
                  },
                  bottomColor: const Color(0xFF1e660e),
                  darkColor: const Color(0xFF1d9c02),
                  lightColor: const Color(0xFF5dfc3a),
                ),
                SizedBox(height: size.height / 9),
                CustomButton(
                  text: '5x5',
                  onPressed: () {
                    final difficultyS = single.Difficulty(name: "5x5", itemCount: 25, crossAxisCount: 5, playerOne: widget.playerOne, playerTwo: 'Triple T');
                    final difficultyD = doubal.Difficulty(name: "5x5", itemCount: 25, crossAxisCount: 5, playerOne: widget.playerOne, playerTwo: widget.playerTwo);
                    widget.playType == 'double'
                        ? moveToNextScreen(context, doubal.TwoPlayerScreen(difficulty: difficultyD))
                        : moveToNextScreen(context, single.SinglePlayerScreen(difficulty: difficultyS));
                  },
                  bottomColor: const Color(0xFF7a260d),
                  darkColor: const Color(0xFFCC3102),
                  lightColor: const Color(0xFFFF6C40),
                ),
                SizedBox(height: size.height / 10),
                GestureDetector(
                  onTap: () {
                    moveToNextScreen(context, PlayerSelection(playType: widget.playType));
                  },
                  child: Image.asset('assets/images/back.png', height: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
