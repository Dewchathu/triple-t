import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt')
  ];

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @audio_sound.
  ///
  /// In en, this message translates to:
  /// **'Audio & Sound'**
  String get audio_sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @sound_effects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get sound_effects;

  /// No description provided for @gameplay_rules.
  ///
  /// In en, this message translates to:
  /// **'Gameplay Rules'**
  String get gameplay_rules;

  /// No description provided for @blitz_mode.
  ///
  /// In en, this message translates to:
  /// **'Blitz Mode (Timer)'**
  String get blitz_mode;

  /// No description provided for @turn_timer.
  ///
  /// In en, this message translates to:
  /// **'Turn Timer'**
  String get turn_timer;

  /// No description provided for @obstacles_mode.
  ///
  /// In en, this message translates to:
  /// **'Obstacles Mode'**
  String get obstacles_mode;

  /// No description provided for @custom_symbols.
  ///
  /// In en, this message translates to:
  /// **'Custom Symbols'**
  String get custom_symbols;

  /// No description provided for @p1_symbol.
  ///
  /// In en, this message translates to:
  /// **'P1 Symbol'**
  String get p1_symbol;

  /// No description provided for @p2_symbol.
  ///
  /// In en, this message translates to:
  /// **'P2/AI Symbol'**
  String get p2_symbol;

  /// No description provided for @visual_themes.
  ///
  /// In en, this message translates to:
  /// **'Visual Themes'**
  String get visual_themes;

  /// No description provided for @game_statistics.
  ///
  /// In en, this message translates to:
  /// **'Game Statistics'**
  String get game_statistics;

  /// No description provided for @sp_wins.
  ///
  /// In en, this message translates to:
  /// **'Single Player Wins'**
  String get sp_wins;

  /// No description provided for @sp_losses.
  ///
  /// In en, this message translates to:
  /// **'Single Player Losses'**
  String get sp_losses;

  /// No description provided for @sp_draws.
  ///
  /// In en, this message translates to:
  /// **'Single Player Draws'**
  String get sp_draws;

  /// No description provided for @current_streak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get current_streak;

  /// No description provided for @best_streak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get best_streak;

  /// No description provided for @mp_p1_wins.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer P1 Wins'**
  String get mp_p1_wins;

  /// No description provided for @mp_p2_wins.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer P2 Wins'**
  String get mp_p2_wins;

  /// No description provided for @mp_draws.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Draws'**
  String get mp_draws;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @ach_first_victory.
  ///
  /// In en, this message translates to:
  /// **'First Victory'**
  String get ach_first_victory;

  /// No description provided for @ach_five_streak.
  ///
  /// In en, this message translates to:
  /// **'5x Win Streak'**
  String get ach_five_streak;

  /// No description provided for @ach_hard_beater.
  ///
  /// In en, this message translates to:
  /// **'Hard AI Defeated'**
  String get ach_hard_beater;

  /// No description provided for @ach_blitz_master.
  ///
  /// In en, this message translates to:
  /// **'Blitz Victory'**
  String get ach_blitz_master;

  /// No description provided for @reset_stats.
  ///
  /// In en, this message translates to:
  /// **'Reset Stats'**
  String get reset_stats;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @single_play.
  ///
  /// In en, this message translates to:
  /// **'Single Play'**
  String get single_play;

  /// No description provided for @play_with_friend.
  ///
  /// In en, this message translates to:
  /// **'Play With Friend'**
  String get play_with_friend;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Name:'**
  String get enter_name;

  /// No description provided for @your_name.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get your_name;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get please_enter_name;

  /// No description provided for @enter_friend_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Friend\'s Name:'**
  String get enter_friend_name;

  /// No description provided for @friend_name.
  ///
  /// In en, this message translates to:
  /// **'Friend\'s name'**
  String get friend_name;

  /// No description provided for @please_enter_friend_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter friend\'s name'**
  String get please_enter_friend_name;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @player_1.
  ///
  /// In en, this message translates to:
  /// **'Player 1'**
  String get player_1;

  /// No description provided for @player_2.
  ///
  /// In en, this message translates to:
  /// **'Player 2'**
  String get player_2;

  /// No description provided for @select_difficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get select_difficulty;

  /// No description provided for @start_game.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get start_game;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @time_left.
  ///
  /// In en, this message translates to:
  /// **'Time Left'**
  String get time_left;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @p1_wins.
  ///
  /// In en, this message translates to:
  /// **'P1 Wins'**
  String get p1_wins;

  /// No description provided for @p2_wins.
  ///
  /// In en, this message translates to:
  /// **'P2 Wins'**
  String get p2_wins;

  /// No description provided for @draws.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get draws;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner! 🎉'**
  String get winner;

  /// No description provided for @you_lost.
  ///
  /// In en, this message translates to:
  /// **'You Lost!'**
  String get you_lost;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @draw_outcome.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Draw'**
  String get draw_outcome;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @exit_confirm.
  ///
  /// In en, this message translates to:
  /// **'Exit Confirmation'**
  String get exit_confirm;

  /// No description provided for @exit_prompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit?'**
  String get exit_prompt;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @prep_arena.
  ///
  /// In en, this message translates to:
  /// **'PREPARING ARENA...'**
  String get prep_arena;

  /// No description provided for @align_to_win.
  ///
  /// In en, this message translates to:
  /// **'Align {marks} to Win!'**
  String align_to_win(String marks);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
