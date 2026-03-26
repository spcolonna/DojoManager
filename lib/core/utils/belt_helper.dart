String beltDisplayName(String titleKey, dynamic loc) => switch (titleKey) {
  'belt_white'     => loc.beltWhite,
  'belt_yellow'    => loc.beltYellow,
  'belt_orange'    => loc.beltOrange,
  'belt_green'     => loc.beltGreen,
  'belt_blue'      => loc.beltBlue,
  'belt_purple'    => loc.beltPurple,
  'belt_brown'     => loc.beltBrown,
  'belt_red'       => loc.beltRed,
  'belt_red_black' => loc.beltRedBlack,
  'belt_black'     => loc.beltBlack,
  _                => titleKey,
};

String styleDisplayName(String styleId, dynamic loc) => switch (styleId) {
  'kung_fu'   => loc.styleKungFu,
  'karate'    => loc.styleKarate,
  'taekwondo' => loc.styleTaekwondo,
  'judo'      => loc.styleJudo,
  'muay_thai' => loc.styleMuayThai,
  'bjj'       => loc.styleBjj,
  'boxing'    => loc.styleBoxing,
  'mma'       => loc.styleMma,
  _           => styleId,
};