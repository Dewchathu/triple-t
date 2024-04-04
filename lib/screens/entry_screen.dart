import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/player_selection.dart';
import 'package:triple_t/widgets/custom_button.dart';

import 'home_screen.dart';

class EntryScreen extends StatefulWidget {
  final String playerOne;
  final String playerTwo;
  const EntryScreen({Key? key, required this.playerOne, required this.playerTwo}) : super(key: key);

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class _EntryScreenState extends State<EntryScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: _kDefaultRainbowColors,
                ),
              ),
            Image.asset(
              'assets/images/entry screen.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Player 1', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.playerOne,style: const TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Player 2',style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.playerTwo,style: const TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            SizedBox(height: size.height/10),
            CustomButton(
              text: 'Easy',
              onPressed: (){
                final difficulty = Difficulty(name: "Easy", itemCount: 9,  crossAxisCount: 3, playerOne: widget.playerOne, playerTwo: widget.playerTwo);
                moveToNextScreen(context, HomeScreen(difficulty: difficulty));
              },
              bottomColor: const Color(0xFFCD8F0A),
              darkColor: const Color(0xFFF19F03),
              lightColor: const Color(0xFFFFEC48),
            ),
            SizedBox(height: size.height/9),
            CustomButton(
              text: 'Medium',
              onPressed: (){
                final difficulty = Difficulty(name: "Medium", itemCount: 16,  crossAxisCount: 4, playerOne: widget.playerOne, playerTwo: widget.playerTwo);
                moveToNextScreen(context, HomeScreen(difficulty: difficulty));
              },
              bottomColor: const Color(0xFF1e660e),
              darkColor: const Color(0xFF1d9c02),
              lightColor: const Color(0xFF5dfc3a),
            ),
            SizedBox(height: size.height/9),
            CustomButton(
              text: 'Hard',
              onPressed: (){
                final difficulty = Difficulty(name: "Hard", itemCount: 25,  crossAxisCount: 5, playerOne: widget.playerOne, playerTwo: widget.playerTwo);
                moveToNextScreen(context, HomeScreen(difficulty: difficulty));
              },
              bottomColor: const Color(0xFF7a260d),
              darkColor: const Color(0xFFCC3102),
              lightColor: const Color(0xFFFF6C40),

            ),
            SizedBox(height: size.height/10),
            GestureDetector(
              onTap: (){
                moveToNextScreen(context, const PlayerSelection());
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
