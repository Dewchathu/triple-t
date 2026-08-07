import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:triple_t/l10n/generated/app_localizations.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/screens/splash_screen.dart';

void main() async {
  try {
    GoogleFonts.config.allowRuntimeFetching = false;
    WidgetsFlutterBinding.ensureInitialized();
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'theme.mp3',
      'transition.mp3',
      'button_click.mp3',
      'move.mp3',
      'win.mp3',
      'draw.mp3',
      'hover.mp3',
      'select.mp3',
      'invalid.mp3',
      'lost.mp3',
    ]).catchError((e) {
      print('Error loading audio assets: $e');
    });

    runApp(const MyApp());
  } catch (e) {
    print('Error in main: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SoundProvider()..initializeMusic()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return MaterialApp(
            title: 'Triple-T',
            locale: Locale(gameProvider.language),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
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
        },
      ),
    );
  }
}
