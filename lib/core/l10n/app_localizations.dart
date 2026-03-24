import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Grand Dojo'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Build your legacy. Train champions.'**
  String get splashTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Master'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey'**
  String get loginSubtitle;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogle;

  /// No description provided for @loginApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginApple;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get loginEmail;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// No description provided for @loginEnterDojo.
  ///
  /// In en, this message translates to:
  /// **'ENTER THE DOJO'**
  String get loginEnterDojo;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get loginCreateAccount;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get loginPasswordLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailEmpty;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordEmpty;

  /// No description provided for @loginPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordShort;

  /// No description provided for @loginAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get loginAlreadyHaveAccount;

  /// No description provided for @loginLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginLogIn;

  /// No description provided for @loginDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginDontHaveAccount;

  /// No description provided for @loginBeginJourney.
  ///
  /// In en, this message translates to:
  /// **'Begin your journey'**
  String get loginBeginJourney;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Master'**
  String get loginWelcomeBack;

  /// No description provided for @onboardingSchoolNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name Your School'**
  String get onboardingSchoolNameTitle;

  /// No description provided for @onboardingSchoolNameLabel.
  ///
  /// In en, this message translates to:
  /// **'What will your school be called?'**
  String get onboardingSchoolNameLabel;

  /// No description provided for @onboardingSchoolNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your dojo name'**
  String get onboardingSchoolNameHint;

  /// No description provided for @onboardingSchoolNameError.
  ///
  /// In en, this message translates to:
  /// **'Name must be between 3 and 30 characters'**
  String get onboardingSchoolNameError;

  /// No description provided for @onboardingChooseStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Martial Art'**
  String get onboardingChooseStyleTitle;

  /// No description provided for @onboardingChooseStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each style has its own strengths. Choose wisely.'**
  String get onboardingChooseStyleSubtitle;

  /// No description provided for @onboardingConfirmStyleCta.
  ///
  /// In en, this message translates to:
  /// **'This is my path →'**
  String get onboardingConfirmStyleCta;

  /// No description provided for @styleKungFu.
  ///
  /// In en, this message translates to:
  /// **'Kung Fu'**
  String get styleKungFu;

  /// No description provided for @styleKungFuDesc.
  ///
  /// In en, this message translates to:
  /// **'Harmony of body and mind. Superior technique and mental clarity.'**
  String get styleKungFuDesc;

  /// No description provided for @styleKarate.
  ///
  /// In en, this message translates to:
  /// **'Karate'**
  String get styleKarate;

  /// No description provided for @styleKarateDesc.
  ///
  /// In en, this message translates to:
  /// **'Discipline and power. Strength and technique in perfect balance.'**
  String get styleKarateDesc;

  /// No description provided for @styleTaekwondo.
  ///
  /// In en, this message translates to:
  /// **'Taekwondo'**
  String get styleTaekwondo;

  /// No description provided for @styleTaekwondoDesc.
  ///
  /// In en, this message translates to:
  /// **'Speed above all. Explosive kicks that keep opponents at distance.'**
  String get styleTaekwondoDesc;

  /// No description provided for @styleJudo.
  ///
  /// In en, this message translates to:
  /// **'Judo'**
  String get styleJudo;

  /// No description provided for @styleJudoDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your opponent\'s force. Unbreakable guard and devastating throws.'**
  String get styleJudoDesc;

  /// No description provided for @styleMuayThai.
  ///
  /// In en, this message translates to:
  /// **'Muay Thai'**
  String get styleMuayThai;

  /// No description provided for @styleMuayThaiDesc.
  ///
  /// In en, this message translates to:
  /// **'The art of eight limbs. Raw power backed by ironclad conditioning.'**
  String get styleMuayThaiDesc;

  /// No description provided for @styleBjj.
  ///
  /// In en, this message translates to:
  /// **'BJJ'**
  String get styleBjj;

  /// No description provided for @styleBjjDesc.
  ///
  /// In en, this message translates to:
  /// **'The ground is your kingdom. Technical dominance and iron defense.'**
  String get styleBjjDesc;

  /// No description provided for @styleBoxing.
  ///
  /// In en, this message translates to:
  /// **'Boxing'**
  String get styleBoxing;

  /// No description provided for @styleBoxingDesc.
  ///
  /// In en, this message translates to:
  /// **'Pure striking art. Power and speed that can end any fight.'**
  String get styleBoxingDesc;

  /// No description provided for @styleMma.
  ///
  /// In en, this message translates to:
  /// **'MMA'**
  String get styleMma;

  /// No description provided for @styleMmaDesc.
  ///
  /// In en, this message translates to:
  /// **'The complete fighter. No weaknesses, no limits.'**
  String get styleMmaDesc;

  /// No description provided for @narrativeStart.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get narrativeStart;

  /// No description provided for @beltWhite.
  ///
  /// In en, this message translates to:
  /// **'White Belt'**
  String get beltWhite;

  /// No description provided for @beltYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow Belt'**
  String get beltYellow;

  /// No description provided for @beltOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange Belt'**
  String get beltOrange;

  /// No description provided for @beltGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Belt'**
  String get beltGreen;

  /// No description provided for @beltBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue Belt'**
  String get beltBlue;

  /// No description provided for @beltPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple Belt'**
  String get beltPurple;

  /// No description provided for @beltBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown Belt'**
  String get beltBrown;

  /// No description provided for @beltRed.
  ///
  /// In en, this message translates to:
  /// **'Red Belt'**
  String get beltRed;

  /// No description provided for @beltRedBlack.
  ///
  /// In en, this message translates to:
  /// **'Red-Black Belt'**
  String get beltRedBlack;

  /// No description provided for @beltBlack.
  ///
  /// In en, this message translates to:
  /// **'Black Belt'**
  String get beltBlack;

  /// No description provided for @strategyAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get strategyAggressive;

  /// No description provided for @strategyAggressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'High-frequency attacks. Burns stamina fast. High risk, high reward.'**
  String get strategyAggressiveDesc;

  /// No description provided for @strategyDefensive.
  ///
  /// In en, this message translates to:
  /// **'Defensive'**
  String get strategyDefensive;

  /// No description provided for @strategyDefensiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Wait and counter. Low stamina cost. Efficient but slow-scoring.'**
  String get strategyDefensiveDesc;

  /// No description provided for @strategyTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get strategyTechnical;

  /// No description provided for @strategyTechnicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Score through precision. Balanced and sustainable.'**
  String get strategyTechnicalDesc;

  /// No description provided for @strategyGrappling.
  ///
  /// In en, this message translates to:
  /// **'Grappling'**
  String get strategyGrappling;

  /// No description provided for @strategyGrapplingDesc.
  ///
  /// In en, this message translates to:
  /// **'Seek takedowns and dominant positions. High reward if successful.'**
  String get strategyGrapplingDesc;

  /// No description provided for @strategyAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get strategyAdaptive;

  /// No description provided for @strategyAdaptiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Reads the opponent and adjusts. Requires high Mentality stat.'**
  String get strategyAdaptiveDesc;

  /// No description provided for @trainingPlanIntenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get trainingPlanIntenseTitle;

  /// No description provided for @trainingPlanIntenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum load on chosen attributes. High gains, high fatigue.'**
  String get trainingPlanIntenseDesc;

  /// No description provided for @trainingPlanBalancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get trainingPlanBalancedTitle;

  /// No description provided for @trainingPlanBalancedDesc.
  ///
  /// In en, this message translates to:
  /// **'All attributes trained equally. Moderate fatigue.'**
  String get trainingPlanBalancedDesc;

  /// No description provided for @trainingPlanTechnicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get trainingPlanTechnicalTitle;

  /// No description provided for @trainingPlanTechnicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on Technique and Mentality. Low fatigue.'**
  String get trainingPlanTechnicalDesc;

  /// No description provided for @trainingPlanRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get trainingPlanRecoveryTitle;

  /// No description provided for @trainingPlanRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Rest and heal. No gains but full stamina for the tournament.'**
  String get trainingPlanRecoveryDesc;

  /// No description provided for @trainingPlanSparringTitle.
  ///
  /// In en, this message translates to:
  /// **'Sparring'**
  String get trainingPlanSparringTitle;

  /// No description provided for @trainingPlanSparringDesc.
  ///
  /// In en, this message translates to:
  /// **'Simulated combat. Bonus XP and random attribute gains.'**
  String get trainingPlanSparringDesc;

  /// No description provided for @trainingPlanIntensivePlusTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensive Plus'**
  String get trainingPlanIntensivePlusTitle;

  /// No description provided for @trainingPlanIntensivePlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Like Intense but 50% more gains. Small injury risk.'**
  String get trainingPlanIntensivePlusDesc;

  /// No description provided for @trainingPlanMasterSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Master Session'**
  String get trainingPlanMasterSessionTitle;

  /// No description provided for @trainingPlanMasterSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Elite training. Maximum gains. Style-specific only.'**
  String get trainingPlanMasterSessionDesc;

  /// No description provided for @upgradeBasicTrainingRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Training Room'**
  String get upgradeBasicTrainingRoomTitle;

  /// No description provided for @upgradeBasicTrainingRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'+1 student slot. Your dojo can now accommodate three students.'**
  String get upgradeBasicTrainingRoomDesc;

  /// No description provided for @upgradeExpandedTatamiTitle.
  ///
  /// In en, this message translates to:
  /// **'Expanded Tatami'**
  String get upgradeExpandedTatamiTitle;

  /// No description provided for @upgradeExpandedTatamiDesc.
  ///
  /// In en, this message translates to:
  /// **'+1 student slot. More mat space, more fighters.'**
  String get upgradeExpandedTatamiDesc;

  /// No description provided for @upgradeCardioAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Cardio Zone'**
  String get upgradeCardioAreaTitle;

  /// No description provided for @upgradeCardioAreaDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduces weekly fatigue by 10% for all students.'**
  String get upgradeCardioAreaDesc;

  /// No description provided for @upgradeLockerRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Locker Room'**
  String get upgradeLockerRoomTitle;

  /// No description provided for @upgradeLockerRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'+1 student slot. A proper dojo needs proper facilities.'**
  String get upgradeLockerRoomDesc;

  /// No description provided for @upgradeMartialLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Martial Arts Library'**
  String get upgradeMartialLibraryTitle;

  /// No description provided for @upgradeMartialLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'+5% XP for all students. Knowledge accelerates mastery.'**
  String get upgradeMartialLibraryDesc;

  /// No description provided for @upgradeSparringRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Sparring Room'**
  String get upgradeSparringRoomTitle;

  /// No description provided for @upgradeSparringRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Dedicated sparring space. Unlocks double sparring sessions.'**
  String get upgradeSparringRoomDesc;

  /// No description provided for @upgradeFullDojoTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Dojo'**
  String get upgradeFullDojoTitle;

  /// No description provided for @upgradeFullDojoDesc.
  ///
  /// In en, this message translates to:
  /// **'+2 student slots. Your school has reached its full potential.'**
  String get upgradeFullDojoDesc;

  /// No description provided for @currencyMD.
  ///
  /// In en, this message translates to:
  /// **'Dojo Coins'**
  String get currencyMD;

  /// No description provided for @currencyGM.
  ///
  /// In en, this message translates to:
  /// **'Master Gems'**
  String get currencyGM;

  /// No description provided for @currencyPH.
  ///
  /// In en, this message translates to:
  /// **'Skill Points'**
  String get currencyPH;

  /// No description provided for @currencyMDShort.
  ///
  /// In en, this message translates to:
  /// **'DC'**
  String get currencyMDShort;

  /// No description provided for @currencyGMShort.
  ///
  /// In en, this message translates to:
  /// **'GM'**
  String get currencyGMShort;

  /// No description provided for @navDojo.
  ///
  /// In en, this message translates to:
  /// **'Dojo'**
  String get navDojo;

  /// No description provided for @navTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get navTraining;

  /// No description provided for @navTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get navTournament;

  /// No description provided for @navStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get navStudents;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Grand Master'**
  String get dashboardTitle;

  /// No description provided for @dashboardMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get dashboardMessages;

  /// No description provided for @dashboardReputation.
  ///
  /// In en, this message translates to:
  /// **'Reputation'**
  String get dashboardReputation;

  /// No description provided for @dashboardWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week} · Season {season}'**
  String dashboardWeekLabel(int week, int season);

  /// No description provided for @fightRoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String fightRoundLabel(int round);

  /// No description provided for @messageFirstTournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'You Are Required to Compete'**
  String get messageFirstTournamentTitle;

  /// No description provided for @messageFirstTournamentBody.
  ///
  /// In en, this message translates to:
  /// **'The Regional Council of Martial Arts has registered your school. As a new dojo in the region, participation in the Weekly Tournament is mandatory. Your students will be judged by their belt rank. Make it count, Master.\n\n— The Council'**
  String get messageFirstTournamentBody;

  /// No description provided for @skillBranchPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get skillBranchPower;

  /// No description provided for @skillBranchAgility.
  ///
  /// In en, this message translates to:
  /// **'Agility'**
  String get skillBranchAgility;

  /// No description provided for @skillBranchTechnique.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get skillBranchTechnique;

  /// No description provided for @skillBranchGuard.
  ///
  /// In en, this message translates to:
  /// **'Guard'**
  String get skillBranchGuard;

  /// No description provided for @skillBranchMind.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get skillBranchMind;

  /// No description provided for @skillHeavyStrike.
  ///
  /// In en, this message translates to:
  /// **'Heavy Strike'**
  String get skillHeavyStrike;

  /// No description provided for @skillTakedown.
  ///
  /// In en, this message translates to:
  /// **'Takedown'**
  String get skillTakedown;

  /// No description provided for @skillRawPower.
  ///
  /// In en, this message translates to:
  /// **'Raw Power'**
  String get skillRawPower;

  /// No description provided for @skillSprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint'**
  String get skillSprint;

  /// No description provided for @skillEvasion.
  ///
  /// In en, this message translates to:
  /// **'Evasion'**
  String get skillEvasion;

  /// No description provided for @skillMaxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Max Speed'**
  String get skillMaxSpeed;

  /// No description provided for @skillPrecision.
  ///
  /// In en, this message translates to:
  /// **'Precision'**
  String get skillPrecision;

  /// No description provided for @skillCounterTech.
  ///
  /// In en, this message translates to:
  /// **'Counter Technique'**
  String get skillCounterTech;

  /// No description provided for @skillTechniqueMaster.
  ///
  /// In en, this message translates to:
  /// **'Technique Master'**
  String get skillTechniqueMaster;

  /// No description provided for @skillBasicBlock.
  ///
  /// In en, this message translates to:
  /// **'Basic Block'**
  String get skillBasicBlock;

  /// No description provided for @skillArmor.
  ///
  /// In en, this message translates to:
  /// **'Armor'**
  String get skillArmor;

  /// No description provided for @skillBunker.
  ///
  /// In en, this message translates to:
  /// **'Bunker'**
  String get skillBunker;

  /// No description provided for @skillAnticipation.
  ///
  /// In en, this message translates to:
  /// **'Anticipation'**
  String get skillAnticipation;

  /// No description provided for @skillFightReading.
  ///
  /// In en, this message translates to:
  /// **'Fight Reading'**
  String get skillFightReading;

  /// No description provided for @skillGrandStrategist.
  ///
  /// In en, this message translates to:
  /// **'Grand Strategist'**
  String get skillGrandStrategist;

  /// No description provided for @shopGemStarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Starter Pack'**
  String get shopGemStarterLabel;

  /// No description provided for @shopGemStarterDesc.
  ///
  /// In en, this message translates to:
  /// **'Begin your journey as Grand Master.'**
  String get shopGemStarterDesc;

  /// No description provided for @shopGemAdvancedLabel.
  ///
  /// In en, this message translates to:
  /// **'Advanced Pack'**
  String get shopGemAdvancedLabel;

  /// No description provided for @shopGemAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Serious training requires serious resources.'**
  String get shopGemAdvancedDesc;

  /// No description provided for @shopGemGrandMasterLabel.
  ///
  /// In en, this message translates to:
  /// **'Grand Master Pack'**
  String get shopGemGrandMasterLabel;

  /// No description provided for @shopGemGrandMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Best value. 20% bonus gems.'**
  String get shopGemGrandMasterDesc;

  /// No description provided for @shopGemLegendaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Legendary Pack'**
  String get shopGemLegendaryLabel;

  /// No description provided for @shopGemLegendaryDesc.
  ///
  /// In en, this message translates to:
  /// **'For masters who accept no limits. 35% bonus.'**
  String get shopGemLegendaryDesc;

  /// No description provided for @shopPassMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Master Pass — Monthly'**
  String get shopPassMonthlyLabel;

  /// No description provided for @shopPassMonthlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Boost your school every month.'**
  String get shopPassMonthlyDesc;

  /// No description provided for @shopPassAnnualLabel.
  ///
  /// In en, this message translates to:
  /// **'Master Pass — Annual'**
  String get shopPassAnnualLabel;

  /// No description provided for @shopPassAnnualDesc.
  ///
  /// In en, this message translates to:
  /// **'The complete Grand Master experience.'**
  String get shopPassAnnualDesc;

  /// No description provided for @shopPassAnnualSavings.
  ///
  /// In en, this message translates to:
  /// **'Save 41% vs monthly'**
  String get shopPassAnnualSavings;

  /// No description provided for @shopPassBenefitMdBonus.
  ///
  /// In en, this message translates to:
  /// **'+30% Dojo Coins in tournaments'**
  String get shopPassBenefitMdBonus;

  /// No description provided for @shopPassBenefitExtraStudentSlot.
  ///
  /// In en, this message translates to:
  /// **'+1 student slot in your roster'**
  String get shopPassBenefitExtraStudentSlot;

  /// No description provided for @shopPassBenefitWeeklyScout.
  ///
  /// In en, this message translates to:
  /// **'1 free premium scout per week'**
  String get shopPassBenefitWeeklyScout;

  /// No description provided for @shopPassBenefitSpecialTournament.
  ///
  /// In en, this message translates to:
  /// **'1 exclusive tournament per week'**
  String get shopPassBenefitSpecialTournament;

  /// No description provided for @shopPassBenefitSchoolIcon.
  ///
  /// In en, this message translates to:
  /// **'Exclusive school icon & banner'**
  String get shopPassBenefitSchoolIcon;

  /// No description provided for @shopPassBenefitWeeklyGems.
  ///
  /// In en, this message translates to:
  /// **'+10 Master Gems per week'**
  String get shopPassBenefitWeeklyGems;

  /// No description provided for @shopPassBenefitExclusiveTraining.
  ///
  /// In en, this message translates to:
  /// **'Exclusive training plans'**
  String get shopPassBenefitExclusiveTraining;

  /// No description provided for @shopPassBenefitInvitationTournament.
  ///
  /// In en, this message translates to:
  /// **'End-of-season Invitational access'**
  String get shopPassBenefitInvitationTournament;

  /// No description provided for @shopMdSmallLabel.
  ///
  /// In en, this message translates to:
  /// **'1,000 Dojo Coins'**
  String get shopMdSmallLabel;

  /// No description provided for @shopMdMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'5,500 Dojo Coins (+10%)'**
  String get shopMdMediumLabel;

  /// No description provided for @shopMdLargeLabel.
  ///
  /// In en, this message translates to:
  /// **'12,000 Dojo Coins (+20%)'**
  String get shopMdLargeLabel;

  /// No description provided for @shopBundleStarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Starter Bundle'**
  String get shopBundleStarterLabel;

  /// No description provided for @shopBundleStarterDesc.
  ///
  /// In en, this message translates to:
  /// **'200 Gems + 500 Coins. Everything a new Master needs.'**
  String get shopBundleStarterDesc;

  /// No description provided for @shopBundleNewSchoolLabel.
  ///
  /// In en, this message translates to:
  /// **'New School Bundle'**
  String get shopBundleNewSchoolLabel;

  /// No description provided for @shopBundleNewSchoolDesc.
  ///
  /// In en, this message translates to:
  /// **'300 Gems + 1,200 Coins + unlock your second dojo.'**
  String get shopBundleNewSchoolDesc;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsSignOutConfirm;

  /// No description provided for @settingsSignOutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsSignOutCancel;

  /// No description provided for @settingsSignOutConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOutConfirmBtn;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSound;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get settingsMusic;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @statStr.
  ///
  /// In en, this message translates to:
  /// **'STR'**
  String get statStr;

  /// No description provided for @statSpd.
  ///
  /// In en, this message translates to:
  /// **'SPD'**
  String get statSpd;

  /// No description provided for @statTec.
  ///
  /// In en, this message translates to:
  /// **'TEC'**
  String get statTec;

  /// No description provided for @statDef.
  ///
  /// In en, this message translates to:
  /// **'DEF'**
  String get statDef;

  /// No description provided for @statMen.
  ///
  /// In en, this message translates to:
  /// **'MEN'**
  String get statMen;

  /// No description provided for @statRes.
  ///
  /// In en, this message translates to:
  /// **'RES'**
  String get statRes;

  /// No description provided for @statStrFull.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get statStrFull;

  /// No description provided for @statSpdFull.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpdFull;

  /// No description provided for @statTecFull.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get statTecFull;

  /// No description provided for @statDefFull.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get statDefFull;

  /// No description provided for @statMenFull.
  ///
  /// In en, this message translates to:
  /// **'Mentality'**
  String get statMenFull;

  /// No description provided for @statResFull.
  ///
  /// In en, this message translates to:
  /// **'Resistance'**
  String get statResFull;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
