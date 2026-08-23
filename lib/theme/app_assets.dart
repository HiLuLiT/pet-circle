class AppAssets {
  // Onboarding field icons
  static const onboardingCalendarIcon = 'assets/figma/onboarding_calendar.svg';
  static const onboardingPulseIcon = 'assets/figma/onboarding_pulse.svg';

  /// Onboarding "You're all set!" mascot — Figma node 601:1260 ("Object")
  /// inside Step 5 (424:6047). Renders at 136.093x162.697 (aspect 266/318).
  ///
  /// Animated WebP (48 frames, ~2s waving loop, transparent). Flutter's
  /// [Image] plays animated WebP natively, so this needs no extra package.
  /// Pre-scaled to the render box rather than shipped at source resolution:
  /// every frame is decoded at the asset's own size, so an oversized asset
  /// costs both bundle size and per-frame decode for no visible gain.
  static const onboardingAllSetDog =
      'assets/figma/onboarding_all_set_dog.webp';

  // Welcome
  static const welcomeGraphic = 'assets/figma/welcome.svg';
  static const welcomeCat = 'assets/figma/welcome_cat.svg';
  static const welcomeDog = 'assets/figma/welcome_dog.svg';
  static const welcomeCombined = 'assets/figma/welcome_combined.svg';

  /// Welcome/landing hero illustration (Figma DS node 402:1682, layer "Object").
  static const welcomeHero = 'assets/figma/welcome_hero.png';

  /// Welcome hero split into animated layers, from the Claude Design project
  /// "Heart animation for dog" (dog.png / heart.png). [welcomeHero] is the
  /// same artwork pre-composited, kept as the reduced-motion still.
  static const welcomeDogLayer = 'assets/figma/welcome_dog.png';

  /// Pet-card dog artwork — Figma node 442:8893 (renders at 101.198x90).
  static const petCardDog = 'assets/figma/pet_card_dog.png';
  static const welcomeHeartLayer = 'assets/figma/welcome_heart.png';
  static const googleLogo = 'assets/figma/google_logo.png';
  static const appLogo = 'assets/figma/app_logo.svg';
  static const petPlaceholder = 'assets/figma/pet_placeholder.png';

  // Dashboard images
  static const petMax = petPlaceholder;
  static const petLuna = petPlaceholder;
  static const petRocky = petPlaceholder;

  // Care circle avatars
  static const avatar1 =
      'https://ui-avatars.com/api/?name=Owner&size=128&rounded=true';
  static const avatar2 =
      'https://ui-avatars.com/api/?name=Caregiver&size=128&rounded=true';
  static const avatar3 =
      'https://ui-avatars.com/api/?name=Vet&size=128&rounded=true';
  static const avatar4 =
      'https://ui-avatars.com/api/?name=Viewer&size=128&rounded=true';

  // Header icons
  static const globeIcon = 'material:language';
  static const bellIcon = 'material:notifications_none';

  // Dashboard metric icons
  static const bpmIcon = 'material:favorite_border';
  static const bpmIconAlt = 'material:favorite';
  static const careCircleIcon = 'material:group';

  // Summary card icons
  static const statusOkIcon = 'material:check_circle_outline';
  static const attentionIcon = 'material:warning_amber_outlined';
  static const attentionIconInner = 'material:priority_high';
  static const attentionIconDot = 'material:circle';
  static const chartIcon = 'material:bar_chart';
  static const chartIconLine = 'material:show_chart';

  // Onboarding navigation icons
  static const navLeftIcon = 'material:arrow_back';
  static const navRightIcon = 'material:arrow_forward';
  static const dropdownIcon = 'material:keyboard_arrow_down';
  static const radioSelectedIcon = 'material:radio_button_checked';
}
