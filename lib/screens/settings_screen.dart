import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:triple_t/actions/moveto_next_screen.dart';
import 'package:triple_t/providers/sound_provider.dart';
import 'package:triple_t/providers/game_provider.dart';
import 'package:triple_t/screens/entry_screen.dart';
import 'package:triple_t/widgets/custom_button.dart';
import 'package:triple_t/widgets/wavy_gradient_painter.dart';

import '../widgets/exit_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;
  late AnimationController _waveController;

  late TextEditingController _p1SymbolController;
  late TextEditingController _p2SymbolController;

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    _p1SymbolController = TextEditingController(text: gameProvider.playerOneSymbol);
    _p2SymbolController = TextEditingController(text: gameProvider.playerTwoSymbol);

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _titleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _waveController.dispose();
    _p1SymbolController.dispose();
    _p2SymbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final soundProvider = Provider.of<SoundProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Dynamic themer parameters
    Color containerColor = Colors.blue.shade900.withOpacity(0.4);
    Color borderColor = Colors.cyanAccent;
    Color sliderActive = Colors.cyanAccent;
    Color sliderInactive = Colors.blue.shade900;
    Color titleColor = Colors.white;
    Color accentColor = Colors.cyanAccent;
    List<Shadow> titleShadows = [
      Shadow(
        blurRadius: 15.0,
        color: Colors.cyanAccent.withOpacity(0.8),
      ),
    ];

    switch (gameProvider.theme) {
      case GameTheme.classic:
        containerColor = Colors.blue.shade900.withOpacity(0.4);
        borderColor = Colors.cyanAccent;
        sliderActive = Colors.cyanAccent;
        sliderInactive = Colors.blue.shade900;
        titleColor = Colors.white;
        accentColor = Colors.cyanAccent;
        titleShadows = [
          Shadow(
            blurRadius: 15.0,
            color: Colors.cyanAccent.withOpacity(0.8),
          ),
        ];
        break;
      case GameTheme.neon:
        containerColor = const Color(0xFF1E0B36).withOpacity(0.4);
        borderColor = Colors.pinkAccent;
        sliderActive = Colors.pinkAccent;
        sliderInactive = const Color(0xFF1E0B36);
        titleColor = Colors.greenAccent;
        accentColor = Colors.pinkAccent;
        titleShadows = [
          Shadow(blurRadius: 15.0, color: Colors.pinkAccent.withOpacity(0.8))
        ];
        break;
      case GameTheme.chalkboard:
        containerColor = Colors.transparent;
        borderColor = Colors.white70;
        sliderActive = Colors.white;
        sliderInactive = Colors.white24;
        titleColor = Colors.white.withOpacity(0.9);
        accentColor = Colors.white70;
        titleShadows = [];
        break;
      case GameTheme.retro:
        containerColor = Colors.orange.shade900.withOpacity(0.2);
        borderColor = Colors.amber;
        sliderActive = Colors.amberAccent;
        sliderInactive = Colors.orange.shade900;
        titleColor = Colors.yellowAccent;
        accentColor = Colors.amber;
        titleShadows = [
          Shadow(blurRadius: 15.0, color: Colors.redAccent.withOpacity(0.8))
        ];
        break;
      case GameTheme.glassmorphism:
        containerColor = Colors.white.withOpacity(0.08);
        borderColor = Colors.white.withOpacity(0.2);
        sliderActive = Colors.white;
        sliderInactive = Colors.white.withOpacity(0.1);
        titleColor = Colors.white;
        accentColor = Colors.white.withOpacity(0.8);
        titleShadows = [
          Shadow(blurRadius: 10.0, color: Colors.white.withOpacity(0.4))
        ];
        break;
    }

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const EntryScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: WavyGradientPainter(_waveController.value, theme: gameProvider.theme),
                );
              },
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _titleAnimation.value,
                          child: Text(
                            gameProvider.t('settings'),
                            style: GoogleFonts.lemon(
                              fontSize: size.width * 0.08,
                              color: titleColor,
                              shadows: titleShadows,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // LANGUAGE SELECTOR
                    _buildSectionTitle(gameProvider.t('language'), accentColor),
                    DropdownButtonFormField<String>(
                      value: gameProvider.language,
                      dropdownColor: sliderInactive,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.lemon(color: Colors.white, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('ENGLISH (EN)')),
                        DropdownMenuItem(value: 'es', child: Text('ESPAÑOL (ES)')),
                        DropdownMenuItem(value: 'fr', child: Text('FRANÇAIS (FR)')),
                        DropdownMenuItem(value: 'de', child: Text('DEUTSCH (DE)')),
                        DropdownMenuItem(value: 'hi', child: Text('हिन्दी (HI)')),
                        DropdownMenuItem(value: 'pt', child: Text('PORTUGUÊS (PT)')),
                      ],
                      onChanged: (String? newLang) {
                        if (newLang != null) {
                          HapticFeedback.lightImpact();
                          gameProvider.setLanguage(newLang);
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    // MUSIC TOGGLE
                    _buildSectionTitle(gameProvider.t('audio_sound'), accentColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(gameProvider.t('music'), style: GoogleFonts.lemon(fontSize: size.width * 0.04, color: Colors.white)),
                        Switch(
                          value: soundProvider.isMusicOn,
                          activeColor: borderColor,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            soundProvider.toggleMusic();
                          },
                        ),
                      ],
                    ),
                    if (soundProvider.isMusicOn)
                      Row(
                        children: [
                          Icon(Icons.volume_up, color: Colors.white, size: size.width * 0.05),
                          Expanded(
                            child: Slider(
                              value: soundProvider.musicVolume,
                              onChanged: (val) => soundProvider.setMusicVolume(val),
                              activeColor: sliderActive,
                              inactiveColor: sliderInactive,
                            ),
                          ),
                        ],
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(gameProvider.t('sound_effects'), style: GoogleFonts.lemon(fontSize: size.width * 0.04, color: Colors.white)),
                        Switch(
                          value: soundProvider.isEffectsOn,
                          activeColor: borderColor,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            soundProvider.toggleEffects();
                          },
                        ),
                      ],
                    ),
                    if (soundProvider.isEffectsOn)
                      Row(
                        children: [
                          Icon(Icons.vibration, color: Colors.white, size: size.width * 0.05),
                          Expanded(
                            child: Slider(
                              value: soundProvider.effectsVolume,
                              onChanged: (val) => soundProvider.setEffectsVolume(val),
                              activeColor: sliderActive,
                              inactiveColor: sliderInactive,
                            ),
                          ),
                        ],
                      ),

                    // GAMEPLAY MODES
                    const SizedBox(height: 15),
                    _buildSectionTitle(gameProvider.t('gameplay_rules'), accentColor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(gameProvider.t('blitz_mode'), style: GoogleFonts.lemon(fontSize: size.width * 0.04, color: Colors.white)),
                        Switch(
                          value: gameProvider.isBlitzMode,
                          activeColor: borderColor,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            gameProvider.setBlitzMode(val);
                          },
                        ),
                      ],
                    ),
                    if (gameProvider.isBlitzMode)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${gameProvider.t('turn_timer')}: ${gameProvider.blitzDurationSeconds}s',
                              style: GoogleFonts.lemon(fontSize: size.width * 0.035, color: borderColor)),
                          Expanded(
                            child: Slider(
                              value: gameProvider.blitzDurationSeconds.toDouble(),
                              min: 5.0,
                              max: 20.0,
                              divisions: 3,
                              onChanged: (val) {
                                gameProvider.setBlitzMode(true, duration: val.toInt());
                              },
                              activeColor: sliderActive,
                              inactiveColor: sliderInactive,
                            ),
                          ),
                        ],
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(gameProvider.t('obstacles_mode'), style: GoogleFonts.lemon(fontSize: size.width * 0.04, color: Colors.white)),
                        Switch(
                          value: gameProvider.isObstaclesMode,
                          activeColor: borderColor,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            gameProvider.setObstaclesMode(val);
                          },
                        ),
                      ],
                    ),

                    // CUSTOM SYMBOLS
                    const SizedBox(height: 15),
                    _buildSectionTitle(gameProvider.t('custom_symbols'), accentColor),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _p1SymbolController,
                            style: GoogleFonts.lemon(color: Colors.white, fontSize: 16),
                            maxLength: 2,
                            decoration: InputDecoration(
                              labelText: gameProvider.t('p1_symbol'),
                              labelStyle: GoogleFonts.lemon(color: borderColor, fontSize: 12),
                              counterText: '',
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
                            ),
                            onChanged: (val) {
                              gameProvider.setSymbols(val, _p2SymbolController.text);
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _p2SymbolController,
                            style: GoogleFonts.lemon(color: Colors.white, fontSize: 16),
                            maxLength: 2,
                            decoration: InputDecoration(
                              labelText: gameProvider.t('p2_symbol'),
                              labelStyle: GoogleFonts.lemon(color: borderColor, fontSize: 12),
                              counterText: '',
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
                            ),
                            onChanged: (val) {
                              gameProvider.setSymbols(_p1SymbolController.text, val);
                            },
                          ),
                        ),
                      ],
                    ),

                    // THEMES SELECTOR
                    const SizedBox(height: 15),
                    _buildSectionTitle(gameProvider.t('visual_themes'), accentColor),
                    DropdownButtonFormField<GameTheme>(
                      value: gameProvider.theme,
                      dropdownColor: sliderInactive,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.lemon(color: Colors.white, fontSize: 14),
                      items: GameTheme.values.map((GameTheme theme) {
                        return DropdownMenuItem<GameTheme>(
                          value: theme,
                          child: Text(theme.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (GameTheme? newTheme) {
                        if (newTheme != null) {
                          HapticFeedback.lightImpact();
                          gameProvider.setTheme(newTheme);
                        }
                      },
                    ),

                    // STATS & ACHIEVEMENTS RESET
                    const SizedBox(height: 25),
                    _buildSectionTitle(gameProvider.t('game_statistics'), accentColor),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(gameProvider.t('sp_wins'), gameProvider.spWins.toString(), borderColor),
                          _buildStatRow(gameProvider.t('sp_losses'), gameProvider.spLosses.toString(), borderColor),
                          _buildStatRow(gameProvider.t('sp_draws'), gameProvider.spDraws.toString(), borderColor),
                          _buildStatRow(gameProvider.t('current_streak'), gameProvider.spCurrentStreak.toString(), borderColor),
                          _buildStatRow(gameProvider.t('best_streak'), gameProvider.spBestStreak.toString(), borderColor),
                          Divider(color: borderColor),
                          _buildStatRow(gameProvider.t('mp_p1_wins'), gameProvider.mpP1Wins.toString(), borderColor),
                          _buildStatRow(gameProvider.t('mp_p2_wins'), gameProvider.mpP2Wins.toString(), borderColor),
                          _buildStatRow(gameProvider.t('mp_draws'), gameProvider.mpDraws.toString(), borderColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ACHIEVEMENTS SHOWCASE
                    _buildSectionTitle(gameProvider.t('achievements'), accentColor),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          _buildAchievementRow(gameProvider.t('ach_first_victory'), gameProvider.achFirstVictory),
                          _buildAchievementRow(gameProvider.t('ach_five_streak'), gameProvider.achFiveStreak),
                          _buildAchievementRow(gameProvider.t('ach_hard_beater'), gameProvider.achHardBeater),
                          _buildAchievementRow(gameProvider.t('ach_blitz_master'), gameProvider.achBlitzMaster),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    // Reset Stats Button
                    SizedBox(
                      width: size.width * 0.6,
                      child: CustomButton(
                        text: gameProvider.t('reset_stats'),
                        icon: Icons.delete_forever,
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          gameProvider.resetStats();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(gameProvider.t('reset_stats') + '!', style: GoogleFonts.lemon(color: Colors.white)),
                              backgroundColor: Colors.red.shade900,
                            ),
                          );
                        },
                        bottomColor: Colors.red.shade900,
                        darkColor: Colors.red.shade700,
                        lightColor: Colors.red.shade400,
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Back Button
                    SizedBox(
                      width: size.width * 0.6,
                      child: CustomButton(
                        text: gameProvider.t('back'),
                        icon: Icons.arrow_back,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (soundProvider.isEffectsOn) {
                            FlameAudio.play('button_click.mp3', volume: soundProvider.effectsVolume)
                                .catchError((e) => print('Error: $e'));
                          }
                          moveToNextScreen(context, const EntryScreen());
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.lemon(
            fontSize: 16,
            color: accentColor,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: accentColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lemon(color: Colors.white, fontSize: 12)),
          Text(value, style: GoogleFonts.lemon(color: borderColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(String title, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.emoji_events : Icons.lock,
            color: unlocked ? Colors.amber : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.lemon(
              color: unlocked ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            unlocked ? 'UNLOCKED' : 'LOCKED',
            style: GoogleFonts.lemon(
              color: unlocked ? Colors.green : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return await ExitDialog.showExitConfirmationDialog(context) ?? false;
  }
}
