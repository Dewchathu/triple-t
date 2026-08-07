import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameTheme { classic, neon, chalkboard, retro, glassmorphism }

class GameProvider extends ChangeNotifier {
  GameTheme _theme = GameTheme.classic;
  String _playerOneSymbol = 'O';
  String _playerTwoSymbol = 'X';
  bool _isBlitzMode = false;
  int _blitzDurationSeconds = 10; // default 10 seconds
  bool _isObstaclesMode = false;
  String _language = 'en'; // default English

  // Stats
  int _spWins = 0;
  int _spLosses = 0;
  int _spDraws = 0;
  int _spCurrentStreak = 0;
  int _spBestStreak = 0;

  int _mpP1Wins = 0;
  int _mpP2Wins = 0;
  int _mpDraws = 0;

  // Achievements
  bool _achFirstVictory = false;
  bool _achFiveStreak = false;
  bool _achHardBeater = false;
  bool _achBlitzMaster = false;

  GameProvider() {
    _loadFromPrefs();
  }

  // Getters
  GameTheme get theme => _theme;
  String get playerOneSymbol => _playerOneSymbol;
  String get playerTwoSymbol => _playerTwoSymbol;
  bool get isBlitzMode => _isBlitzMode;
  int get blitzDurationSeconds => _blitzDurationSeconds;
  bool get isObstaclesMode => _isObstaclesMode;
  String get language => _language;

  int get spWins => _spWins;
  int get spLosses => _spLosses;
  int get spDraws => _spDraws;
  int get spCurrentStreak => _spCurrentStreak;
  int get spBestStreak => _spBestStreak;

  int get mpP1Wins => _mpP1Wins;
  int get mpP2Wins => _mpP2Wins;
  int get mpDraws => _mpDraws;

  bool get achFirstVictory => _achFirstVictory;
  bool get achFiveStreak => _achFiveStreak;
  bool get achHardBeater => _achHardBeater;
  bool get achBlitzMaster => _achBlitzMaster;

  // Theme update
  void setTheme(GameTheme newTheme) {
    _theme = newTheme;
    _saveToPrefs();
    notifyListeners();
  }

  // Custom symbols
  void setSymbols(String p1, String p2) {
    _playerOneSymbol = p1.isNotEmpty ? p1 : 'O';
    _playerTwoSymbol = p2.isNotEmpty ? p2 : 'X';
    _saveToPrefs();
    notifyListeners();
  }

  // Blitz mode settings
  void setBlitzMode(bool enabled, {int? duration}) {
    _isBlitzMode = enabled;
    if (duration != null) {
      _blitzDurationSeconds = duration;
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Obstacles setting
  void setObstaclesMode(bool enabled) {
    _isObstaclesMode = enabled;
    _saveToPrefs();
    notifyListeners();
  }

  // Language setting
  void setLanguage(String lang) {
    _language = lang;
    _saveToPrefs();
    notifyListeners();
  }

  // Record Single Player Outcome
  void recordSinglePlayerGame(String outcome, String difficulty) {
    if (outcome == 'player') {
      _spWins++;
      _spCurrentStreak++;
      if (_spCurrentStreak > _spBestStreak) {
        _spBestStreak = _spCurrentStreak;
      }
      _achFirstVictory = true;
      if (_spCurrentStreak >= 5) {
        _achFiveStreak = true;
      }
      if (difficulty == 'Hard') {
        _achHardBeater = true;
      }
      if (_isBlitzMode) {
        _achBlitzMaster = true;
      }
    } else if (outcome == 'computer') {
      _spLosses++;
      _spCurrentStreak = 0;
    } else {
      _spDraws++;
      _spCurrentStreak = 0;
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Record Multiplayer Outcome
  void recordMultiplayerGame(String winner) {
    if (winner == 'p1') {
      _mpP1Wins++;
    } else if (winner == 'p2') {
      _mpP2Wins++;
    } else {
      _mpDraws++;
    }
    _saveToPrefs();
    notifyListeners();
  }

  // Reset all stats & achievements
  void resetStats() {
    _spWins = 0;
    _spLosses = 0;
    _spDraws = 0;
    _spCurrentStreak = 0;
    _spBestStreak = 0;
    _mpP1Wins = 0;
    _mpP2Wins = 0;
    _mpDraws = 0;
    _achFirstVictory = false;
    _achFiveStreak = false;
    _achHardBeater = false;
    _achBlitzMaster = false;
    _saveToPrefs();
    notifyListeners();
  }

  // Save & Load SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = GameTheme.values[prefs.getInt('gameTheme') ?? 0];
    _playerOneSymbol = prefs.getString('playerOneSymbol') ?? 'O';
    _playerTwoSymbol = prefs.getString('playerTwoSymbol') ?? 'X';
    _isBlitzMode = prefs.getBool('isBlitzMode') ?? false;
    _blitzDurationSeconds = prefs.getInt('blitzDurationSeconds') ?? 10;
    _isObstaclesMode = prefs.getBool('isObstaclesMode') ?? false;
    _language = prefs.getString('language') ?? 'en';

    // Stats
    _spWins = prefs.getInt('spWins') ?? 0;
    _spLosses = prefs.getInt('spLosses') ?? 0;
    _spDraws = prefs.getInt('spDraws') ?? 0;
    _spCurrentStreak = prefs.getInt('spCurrentStreak') ?? 0;
    _spBestStreak = prefs.getInt('spBestStreak') ?? 0;
    _mpP1Wins = prefs.getInt('mpP1Wins') ?? 0;
    _mpP2Wins = prefs.getInt('mpP2Wins') ?? 0;
    _mpDraws = prefs.getInt('mpDraws') ?? 0;

    // Achievements
    _achFirstVictory = prefs.getBool('achFirstVictory') ?? false;
    _achFiveStreak = prefs.getBool('achFiveStreak') ?? false;
    _achHardBeater = prefs.getBool('achHardBeater') ?? false;
    _achBlitzMaster = prefs.getBool('achBlitzMaster') ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gameTheme', _theme.index);
    await prefs.setString('playerOneSymbol', _playerOneSymbol);
    await prefs.setString('playerTwoSymbol', _playerTwoSymbol);
    await prefs.setBool('isBlitzMode', _isBlitzMode);
    await prefs.setInt('blitzDurationSeconds', _blitzDurationSeconds);
    await prefs.setBool('isObstaclesMode', _isObstaclesMode);
    await prefs.setString('language', _language);

    // Stats
    await prefs.setInt('spWins', _spWins);
    await prefs.setInt('spLosses', _spLosses);
    await prefs.setInt('spDraws', _spDraws);
    await prefs.setInt('spCurrentStreak', _spCurrentStreak);
    await prefs.setInt('spBestStreak', _spBestStreak);
    await prefs.setInt('mpP1Wins', _mpP1Wins);
    await prefs.setInt('mpP2Wins', _mpP2Wins);
    await prefs.setInt('mpDraws', _mpDraws);

    // Achievements
    await prefs.setBool('achFirstVictory', _achFirstVictory);
    await prefs.setBool('achFiveStreak', _achFiveStreak);
    await prefs.setBool('achHardBeater', _achHardBeater);
    await prefs.setBool('achBlitzMaster', _achBlitzMaster);
  }

  // Translation function
  String t(String key) {
    if (_localizedValues[_language] != null && _localizedValues[_language]![key] != null) {
      return _localizedValues[_language]![key]!;
    }
    // Fallback to English
    return _localizedValues['en']?[key] ?? key;
  }

  // Multi-lingual Translation Database
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'play': 'Play',
      'settings': 'Settings',
      'exit': 'Exit',
      'audio_sound': 'Audio & Sound',
      'music': 'Music',
      'sound_effects': 'Sound Effects',
      'gameplay_rules': 'Gameplay Rules',
      'blitz_mode': 'Blitz Mode (Timer)',
      'turn_timer': 'Turn Timer',
      'obstacles_mode': 'Obstacles Mode',
      'custom_symbols': 'Custom Symbols',
      'p1_symbol': 'P1 Symbol',
      'p2_symbol': 'P2/AI Symbol',
      'visual_themes': 'Visual Themes',
      'game_statistics': 'Game Statistics',
      'sp_wins': 'Single Player Wins',
      'sp_losses': 'Single Player Losses',
      'sp_draws': 'Single Player Draws',
      'current_streak': 'Current Streak',
      'best_streak': 'Best Streak',
      'mp_p1_wins': 'Multiplayer P1 Wins',
      'mp_p2_wins': 'Multiplayer P2 Wins',
      'mp_draws': 'Multiplayer Draws',
      'achievements': 'Achievements',
      'ach_first_victory': 'First Victory',
      'ach_five_streak': '5x Win Streak',
      'ach_hard_beater': 'Hard AI Defeated',
      'ach_blitz_master': 'Blitz Victory',
      'reset_stats': 'Reset Stats',
      'back': 'Back',
      'single_play': 'Single Play',
      'play_with_friend': 'Play With Friend',
      'enter_name': 'Enter Your Name:',
      'your_name': 'Your name',
      'please_enter_name': 'Please enter your name',
      'enter_friend_name': 'Enter Your Friend\'s Name:',
      'friend_name': 'Friend\'s name',
      'please_enter_friend_name': 'Please enter friend\'s name',
      'start': 'Start',
      'loading': 'Loading...',
      'player_1': 'Player 1',
      'player_2': 'Player 2',
      'select_difficulty': 'Select Difficulty',
      'start_game': 'Start Game',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'next': 'Next',
      'thinking': 'Thinking...',
      'time_left': 'Time Left',
      'wins': 'Wins',
      'losses': 'Losses',
      'streak': 'Streak',
      'p1_wins': 'P1 Wins',
      'p2_wins': 'P2 Wins',
      'draws': 'Draws',
      'winner': 'Winner! 🎉',
      'you_lost': 'You Lost!',
      'try_again': 'Try Again',
      'draw_outcome': 'It\'s a Draw',
      'ok': 'OK',
      'replay': 'Replay',
      'exit_confirm': 'Exit Confirmation',
      'exit_prompt': 'Do you want to exit?',
      'no': 'No',
      'yes': 'Yes',
      'prep_arena': 'PREPARING ARENA...',
      'align_to_win': 'Align {} to Win!',
      'language': 'Language',
    },
    'es': {
      'play': 'Jugar',
      'settings': 'Ajustes',
      'exit': 'Salir',
      'audio_sound': 'Audio y Sonido',
      'music': 'Música',
      'sound_effects': 'Efectos de Sonido',
      'gameplay_rules': 'Reglas de Juego',
      'blitz_mode': 'Modo Blitz (Temporizador)',
      'turn_timer': 'Temporizador de Turno',
      'obstacles_mode': 'Modo Obstáculos',
      'custom_symbols': 'Símbolos Personalizados',
      'p1_symbol': 'Símbolo P1',
      'p2_symbol': 'Símbolo P2/IA',
      'visual_themes': 'Temas Visuales',
      'game_statistics': 'Estadísticas del Juego',
      'sp_wins': 'Victorias del Jugador',
      'sp_losses': 'Derrotas del Jugador',
      'sp_draws': 'Empates del Jugador',
      'current_streak': 'Racha Actual',
      'best_streak': 'Mejor Racha',
      'mp_p1_wins': 'Victorias Multijugador P1',
      'mp_p2_wins': 'Victorias Multijugador P2',
      'mp_draws': 'Empates Multijugador',
      'achievements': 'Logros',
      'ach_first_victory': 'Primera Victoria',
      'ach_five_streak': 'Racha de 5 Victorias',
      'ach_hard_beater': 'IA Difícil Derrotada',
      'ach_blitz_master': 'Victoria en Blitz',
      'reset_stats': 'Restablecer Estadísticas',
      'back': 'Atrás',
      'single_play': 'Un Jugador',
      'play_with_friend': 'Jugar con Amigo',
      'enter_name': 'Ingresa Tu Nombre:',
      'your_name': 'Tu nombre',
      'please_enter_name': 'Por favor ingresa tu nombre',
      'enter_friend_name': 'Ingresa Nombre de Tu Amigo:',
      'friend_name': 'Nombre de amigo',
      'please_enter_friend_name': 'Por favor ingresa nombre de amigo',
      'start': 'Comenzar',
      'loading': 'Cargando...',
      'player_1': 'Jugador 1',
      'player_2': 'Jugador 2',
      'select_difficulty': 'Seleccionar Dificultad',
      'start_game': 'Comenzar Juego',
      'easy': 'Fácil',
      'medium': 'Medio',
      'hard': 'Difícil',
      'next': 'Siguiente',
      'thinking': 'Pensando...',
      'time_left': 'Tiempo Restante',
      'wins': 'Victorias',
      'losses': 'Derrotas',
      'streak': 'Racha',
      'p1_wins': 'Ganados P1',
      'p2_wins': 'Ganados P2',
      'draws': 'Empates',
      'winner': '¡Ganador! 🎉',
      'you_lost': '¡Perdiste!',
      'try_again': 'Intentar de Nuevo',
      'draw_outcome': 'Es un Empate',
      'ok': 'Aceptar',
      'replay': 'Rejugar',
      'exit_confirm': 'Confirmación de Salida',
      'exit_prompt': '¿Quieres salir?',
      'no': 'No',
      'yes': 'Sí',
      'prep_arena': 'PREPARANDO ARENA...',
      'align_to_win': '¡Alinea {} para Ganar!',
      'language': 'Idioma',
    },
    'fr': {
      'play': 'Jouer',
      'settings': 'Paramètres',
      'exit': 'Quitter',
      'audio_sound': 'Audio et Son',
      'music': 'Musique',
      'sound_effects': 'Effets Sonores',
      'gameplay_rules': 'Règles du Jeu',
      'blitz_mode': 'Mode Blitz (Minuteur)',
      'turn_timer': 'Minuteur de Tour',
      'obstacles_mode': 'Mode Obstacles',
      'custom_symbols': 'Symboles Personnalisés',
      'p1_symbol': 'Symbole P1',
      'p2_symbol': 'Symbole P2/IA',
      'visual_themes': 'Thèmes Visuels',
      'game_statistics': 'Statistiques du Jeu',
      'sp_wins': 'Victoires Solo',
      'sp_losses': 'Défaites Solo',
      'sp_draws': 'Matchs Nuls Solo',
      'current_streak': 'Série Actuelle',
      'best_streak': 'Meilleure Série',
      'mp_p1_wins': 'Victoires Multi P1',
      'mp_p2_wins': 'Victoires Multi P2',
      'mp_draws': 'Matchs Nuls Multi',
      'achievements': 'Succès',
      'ach_first_victory': 'Première Victoire',
      'ach_five_streak': 'Série de 5 Victoires',
      'ach_hard_beater': 'IA Difficile Battue',
      'ach_blitz_master': 'Victoire en Blitz',
      'reset_stats': 'Réinitialiser Stats',
      'back': 'Retour',
      'single_play': 'Mode Solo',
      'play_with_friend': 'Jouer avec un Ami',
      'enter_name': 'Entrez Votre Nom :',
      'your_name': 'Votre nom',
      'please_enter_name': 'Veuillez entrer votre nom',
      'enter_friend_name': 'Entrez le Nom de Votre Ami :',
      'friend_name': 'Nom de l\'ami',
      'please_enter_friend_name': 'Veuillez entrer le nom de votre ami',
      'start': 'Démarrer',
      'loading': 'Chargement...',
      'player_1': 'Joueur 1',
      'player_2': 'Joueur 2',
      'select_difficulty': 'Choisir la Difficulté',
      'start_game': 'Démarrer le Jeu',
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile',
      'next': 'Suivant',
      'thinking': 'Réflexion...',
      'time_left': 'Temps Restant',
      'wins': 'Victoires',
      'losses': 'Défaites',
      'streak': 'Série',
      'p1_wins': 'Victoires P1',
      'p2_wins': 'Victoires P2',
      'draws': 'Nuls',
      'winner': 'Gagnant ! 🎉',
      'you_lost': 'Vous avez perdu !',
      'try_again': 'Réessayer',
      'draw_outcome': 'Match Nul',
      'ok': 'OK',
      'replay': 'Rejouer',
      'exit_confirm': 'Confirmation de Sortie',
      'exit_prompt': 'Voulez-vous quitter ?',
      'no': 'Non',
      'yes': 'Oui',
      'prep_arena': 'PRÉPARATION DE L\'ARÈNE...',
      'align_to_win': 'Alignez {} pour Gagner !',
      'language': 'Langue',
    },
    'de': {
      'play': 'Spielen',
      'settings': 'Einstellungen',
      'exit': 'Beenden',
      'audio_sound': 'Audio & Ton',
      'music': 'Musik',
      'sound_effects': 'Soundeffekte',
      'gameplay_rules': 'Spielregeln',
      'blitz_mode': 'Blitzmodus (Timer)',
      'turn_timer': 'Rundentimer',
      'obstacles_mode': 'Hindernismodus',
      'custom_symbols': 'Eigene Symbole',
      'p1_symbol': 'P1 Symbol',
      'p2_symbol': 'P2/KI Symbol',
      'visual_themes': 'Visuelle Themen',
      'game_statistics': 'Spielstatistiken',
      'sp_wins': 'Einzelspieler Siege',
      'sp_losses': 'Einzelspieler Niederlagen',
      'sp_draws': 'Einzelspieler Unentschieden',
      'current_streak': 'Aktuelle Serie',
      'best_streak': 'Beste Serie',
      'mp_p1_wins': 'Mehrspieler P1 Siege',
      'mp_p2_wins': 'Mehrspieler P2 Siege',
      'mp_draws': 'Mehrspieler Unentschieden',
      'achievements': 'Erfolge',
      'ach_first_victory': 'Erster Sieg',
      'ach_five_streak': '5x Siegesserie',
      'ach_hard_beater': 'Schwere KI Besiegt',
      'ach_blitz_master': 'Blitz-Sieg',
      'reset_stats': 'Statistiken Zurücksetzen',
      'back': 'Zurück',
      'single_play': 'Einzelspieler',
      'play_with_friend': 'Mit Freund Spielen',
      'enter_name': 'Name Eingeben:',
      'your_name': 'Dein Name',
      'please_enter_name': 'Bitte gib deinen Namen ein',
      'enter_friend_name': 'Name Deines Freundes:',
      'friend_name': 'Name des Freundes',
      'please_enter_friend_name': 'Bitte gib den Namen deines Freundes ein',
      'start': 'Start',
      'loading': 'Laden...',
      'player_1': 'Spieler 1',
      'player_2': 'Spieler 2',
      'select_difficulty': 'Schwierigkeit Wählen',
      'start_game': 'Spiel Starten',
      'easy': 'Einfach',
      'medium': 'Mittel',
      'hard': 'Schwer',
      'next': 'Nächster',
      'thinking': 'Nachdenken...',
      'time_left': 'Zeit Übrig',
      'wins': 'Siege',
      'losses': 'Niederlagen',
      'streak': 'Serie',
      'p1_wins': 'P1 Siege',
      'p2_wins': 'P2 Siege',
      'draws': 'Unentschieden',
      'winner': 'Gewinner! 🎉',
      'you_lost': 'Verloren!',
      'try_again': 'Erneut Versuchen',
      'draw_outcome': 'Unentschieden',
      'ok': 'OK',
      'replay': 'Replay',
      'exit_confirm': 'Beenden Bestätigen',
      'exit_prompt': 'Möchtest du beenden?',
      'no': 'Nein',
      'yes': 'Ja',
      'prep_arena': 'ARENA WIRD VORBEREITET...',
      'align_to_win': 'Bringe {} in eine Reihe zum Sieg!',
      'language': 'Sprache',
    },
    'hi': {
      'play': 'खेलें',
      'settings': 'सेटिंग्स',
      'exit': 'बाहर जाएं',
      'audio_sound': 'ऑडियो और ध्वनि',
      'music': 'संगीत',
      'sound_effects': 'ध्वनि प्रभाव',
      'gameplay_rules': 'गेमप्ले नियम',
      'blitz_mode': 'ब्लिट्ज मोड (टाइमर)',
      'turn_timer': 'टर्न टाइमर',
      'obstacles_mode': 'बाधा मोड',
      'custom_symbols': 'कस्टम प्रतीक',
      'p1_symbol': 'P1 प्रतीक',
      'p2_symbol': 'P2/AI प्रतीक',
      'visual_themes': 'विजुअल थीम्स',
      'game_statistics': 'खेल आँकड़े',
      'sp_wins': 'सिंगल प्लेयर जीत',
      'sp_losses': 'सिंगल प्लेयर हार',
      'sp_draws': 'सिंगल प्लेयर ड्रा',
      'current_streak': 'वर्तमान जीत का सिलसिला',
      'best_streak': 'सर्वश्रेष्ठ जीत का सिलसिला',
      'mp_p1_wins': 'मल्टीप्लेयर P1 जीत',
      'mp_p2_wins': 'मल्टीप्लेयर P2 जीत',
      'mp_draws': 'मल्टीप्लेयर ड्रा',
      'achievements': 'उपलब्धियां',
      'ach_first_victory': 'पहली जीत',
      'ach_five_streak': '5x जीत का सिलसिला',
      'ach_hard_beater': 'कठिन AI पराजित',
      'ach_blitz_master': 'ब्लिट्ज जीत',
      'reset_stats': 'आँकड़े रीसेट करें',
      'back': 'पीछे जाएं',
      'single_play': 'सिंगल प्ले',
      'play_with_friend': 'मित्र के साथ खेलें',
      'enter_name': 'अपना नाम दर्ज करें:',
      'your_name': 'आपका नाम',
      'please_enter_name': 'कृपया अपना नाम दर्ज करें',
      'enter_friend_name': 'अपने मित्र का नाम दर्ज करें:',
      'friend_name': 'मित्र का नाम',
      'please_enter_friend_name': 'कृपया मित्र का नाम दर्ज करें',
      'start': 'शुरू करें',
      'loading': 'लोड हो रहा है...',
      'player_1': 'खिलाड़ी 1',
      'player_2': 'खिलाड़ी 2',
      'select_difficulty': 'कठिनाई चुनें',
      'start_game': 'खेल शुरू करें',
      'easy': 'आसान',
      'medium': 'मध्यम',
      'hard': 'कठिन',
      'next': 'अगला',
      'thinking': 'सोच रहा है...',
      'time_left': 'समय शेष',
      'wins': 'जीत',
      'losses': 'हार',
      'streak': 'सिलसिला',
      'p1_wins': 'P1 जीत',
      'p2_wins': 'P2 जीत',
      'draws': 'ड्रा',
      'winner': 'विजेता! 🎉',
      'you_lost': 'आप हार गए!',
      'try_again': 'पुनः प्रयास करें',
      'draw_outcome': 'यह एक ड्रा है',
      'ok': 'ठीक है',
      'replay': 'पुनः खेलें',
      'exit_confirm': 'बाहर निकलने की पुष्टि',
      'exit_prompt': 'क्या आप बाहर जाना चाहते हैं?',
      'no': 'नहीं',
      'yes': 'हाँ',
      'prep_arena': 'मैदान तैयार किया जा रहा है...',
      'align_to_win': 'जीतने के लिए {} संरेखित करें!',
      'language': 'भाषा',
    },
    'pt': {
      'play': 'Jogar',
      'settings': 'Configurações',
      'exit': 'Sair',
      'audio_sound': 'Áudio e Som',
      'music': 'Música',
      'sound_effects': 'Efeitos de Som',
      'gameplay_rules': 'Regras do Jogo',
      'blitz_mode': 'Modo Blitz (Temporizador)',
      'turn_timer': 'Temporizador de Turno',
      'obstacles_mode': 'Modo Obstáculos',
      'custom_symbols': 'Símbolos Personalizados',
      'p1_symbol': 'Símbolo P1',
      'p2_symbol': 'Símbolo P2/IA',
      'visual_themes': 'Temas Visuais',
      'game_statistics': 'Estatísticas do Jogo',
      'sp_wins': 'Vitórias Solo',
      'sp_losses': 'Derrotas Solo',
      'sp_draws': 'Empates Solo',
      'current_streak': 'Sequência Atual',
      'best_streak': 'Melhor Sequência',
      'mp_p1_wins': 'Vitórias Multi P1',
      'mp_p2_wins': 'Vitórias Multi P2',
      'mp_draws': 'Empates Multi',
      'achievements': 'Conquistas',
      'ach_first_victory': 'Primeira Vitória',
      'ach_five_streak': 'Sequência de 5 Vitórias',
      'ach_hard_beater': 'IA Difícil Derrotada',
      'ach_blitz_master': 'Vitória no Blitz',
      'reset_stats': 'Redefinir Estatísticas',
      'back': 'Voltar',
      'single_play': 'Modo Solo',
      'play_with_friend': 'Jogar com Amigo',
      'enter_name': 'Digite Seu Nome:',
      'your_name': 'Seu nome',
      'please_enter_name': 'Por favor, digite seu nome',
      'enter_friend_name': 'Digite o Nome do Amigo:',
      'friend_name': 'Nome do amigo',
      'please_enter_friend_name': 'Por favor, digite o nome do amigo',
      'start': 'Iniciar',
      'loading': 'Carregando...',
      'player_1': 'Jogador 1',
      'player_2': 'Jogador 2',
      'select_difficulty': 'Selecionar Dificuldade',
      'start_game': 'Iniciar Jogo',
      'easy': 'Fácil',
      'medium': 'Médio',
      'hard': 'Difícil',
      'next': 'Próximo',
      'thinking': 'Pensando...',
      'time_left': 'Tempo Restante',
      'wins': 'Vitórias',
      'losses': 'Derrotas',
      'streak': 'Sequência',
      'p1_wins': 'Vitórias P1',
      'p2_wins': 'Vitórias P2',
      'draws': 'Empates',
      'winner': 'Vencedor! 🎉',
      'you_lost': 'Você Perdeu!',
      'try_again': 'Tentar Novamente',
      'draw_outcome': 'É um Empate',
      'ok': 'OK',
      'replay': 'Rejogar',
      'exit_confirm': 'Confirmar Saída',
      'exit_prompt': 'Deseja sair?',
      'no': 'Não',
      'yes': 'Sim',
      'prep_arena': 'PREPARANDO ARENA...',
      'align_to_win': 'Alinhe {} para Vencer!',
      'language': 'Idioma',
    }
  };
}
