import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Condition{
  NEW('New', 0),
  USED_AS_NEW('Used as new', 1),
  USED_IN_GOOD_SHAPE('Used in good shape', 2),
  USED_IN_MEDIUM_SHAPE('Used in medium shape', 3);

  final String title;
  final int idx;
  const Condition(this.title, this.idx);
}

Condition getCondFromIdx(int idx){
  return Condition.values[idx];
}

extension ConditionExtension on Condition {
  String getTitle(AppLocalizations localization) {
    switch (this) {
      case Condition.NEW:
        return localization.conditionNew;
      case Condition.USED_AS_NEW:
        return localization.conditionUsedAsNew;
      case Condition.USED_IN_GOOD_SHAPE:
        return localization.conditionUsedInGoodShape;
      case Condition.USED_IN_MEDIUM_SHAPE:
        return localization.conditionUsed;
    }
  }
}