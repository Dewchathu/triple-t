import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                text: 'Easy Mode',
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
                text: 'Medium Mode',
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
                text: 'Hard Mode',
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
      ),
    );
  }
}
