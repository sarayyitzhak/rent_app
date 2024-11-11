import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

class Dictionary {

  static AppLocalizations getLocalization(BuildContext context) {
    return AppLocalizations.of(context) ?? AppLocalizationsEn();
  }
}
