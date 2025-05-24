import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/screens/splash_screen.dart';

void main() async {
  try {
    // Disable runtime font fetching for GoogleFonts
    GoogleFonts.config.allowRuntimeFetching = false;

    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // // Initialize FlameAudio
    // await FlameAudio.bgm.initialize();

    // Preload all audio assets
    await FlameAudio.audioCache.loadAll([
      'assets/audio/music.ogg',
      'assets/audio/button_click.mp3',
      'assets/audio/move.mp3',
      'assets/audio/win.mp3',
      'assets/audio/draw.mp3',
      'assets/audio/hover.mp3',
      'assets/audio/select.mp3',
      'assets/audio/invalid.mp3',
      'assets/audio/transition.mp3',
    ]).catchError((e) {
      print('Error loading audio assets: $e');
    });

    // Run the app with SoundProvider
    runApp(
      ChangeNotifierProvider(
        create: (_) => SoundProvider(),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error in main: $e');
    // Fallback: Run app without audio
    runApp(
      ChangeNotifierProvider(
        create: (_) => SoundProvider(),
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triple-T',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.lemonTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        textTheme: GoogleFonts.lemonTextTheme(),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
