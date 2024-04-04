import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/custom_form_field.dart';

import '../widgets/exit_dialog.dart';
import 'entry_screen.dart';

class PlayerSelection extends StatefulWidget {
  const PlayerSelection({Key? key}) : super(key: key);

  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final TextEditingController playerOne = TextEditingController();
    final TextEditingController playerTwo = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child:SizedBox(
              height: size.height,
              width: size.width,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height/9),
                      Center(
                          child: Text('Triple-T',
                            style: GoogleFonts.lemon(
                            fontSize: 30,
                            color: Colors.white,
                          ),),
                      ),
                      const SizedBox(height: 40),
                      const Text('Enter Player 1 Name:'),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: 'Player 1',
                        controller: playerOne,
                        validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter player 1 Name';
                        }
                        return null;
                      },
                      ),
                      const SizedBox(height: 40),
                      const Text('Enter Player 2 Name:'),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: 'Player 2',
                        controller: playerTwo,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Player 2 Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 80),
                      Center(
                        child: CustomButton(
                            text:  'Start',
                            onPressed: (){
                              if (_formKey.currentState?.validate() ?? false) {
                                moveToNextScreen(context, EntryScreen(playerOne: playerOne.text, playerTwo: playerTwo.text,));

                              }
                            },
                            bottomColor: const Color(0xFF0c3363),
                            darkColor: const Color(0xFF0a60c9),
                            lightColor: const Color(0xFF4a9bff),
                        ),
                      ),
                      const SizedBox(height: 80),
                      GestureDetector(
                        onTap: () => _onBackPressed(context),
                          child: Center(child: Text("Exit", style: TextStyle(fontSize: 25),)),
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
  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitDialog.showExitConfirmationDialog(context) ?? false;
  }
}

