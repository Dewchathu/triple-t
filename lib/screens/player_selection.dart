import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/screens/play_type_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/custom_form_field.dart';

import 'game_mode_screen.dart';

class PlayerSelection extends StatefulWidget {
  final String playType;
  const PlayerSelection({Key? key, required this.playType}) : super(key: key);

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
  late TextEditingController playerOneController;
  late TextEditingController playerTwoController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    playerOneController = TextEditingController();
    playerTwoController = TextEditingController();
  }

  @override
  void dispose() {
    playerOneController.dispose();
    playerTwoController.dispose();
    super.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height / 9),
                    Center(
                      child: Text(
                        'Triple-T',
                        style: GoogleFonts.lemon(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text('Enter Your Name:'),
                    const SizedBox(height: 10),
                    CustomFormField(
                      hintText: 'Your name',
                      controller: playerOneController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    if (widget.playType == 'double') ...[
                      const Text('Enter Your Friend\'s name:'),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: 'Friend\'s name',
                        controller: playerTwoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Friend\'s name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                    Center(
                      child: CustomButton(
                        text: 'Start',
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            moveToNextScreen(
                              context,
                              GameModeScreen(
                                playerOne: playerOneController.text,
                                playerTwo: widget.playType == 'double' ? playerTwoController.text : '',
                                playType: widget.playType,
                              ),
                            );
                          }
                        },
                        bottomColor: const Color(0xFF0c3363),
                        darkColor: const Color(0xFF0a60c9),
                        lightColor: const Color(0xFF4a9bff),
                      ),
                    ),
                    const SizedBox(height: 80),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          moveToNextScreen(context, const PlayTypeScreen());
                        },
                        child: Image.asset('assets/images/back.png', height: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
