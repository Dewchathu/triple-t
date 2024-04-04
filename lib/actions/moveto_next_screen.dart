import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

moveToNextScreen(BuildContext context, Widget nxtScreen, [PageTransitionType type = PageTransitionType.fade]){
  Navigator.push(
      context,
      PageTransition(
          type: type,
          duration: const Duration(milliseconds: 600),
          child: nxtScreen
      )
  );
}
