import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum RequestStatus{
  WAITING,
  APPROVED,
  REJECTED,
}

RequestStatus getRequestStatus(int idx){
  return RequestStatus.values[idx];
}


extension RequestStatusExtension on RequestStatus {
  String getTitle(AppLocalizations localization) {
    switch (this) {
      case RequestStatus.WAITING:
        return localization.waiting;
      case RequestStatus.REJECTED:
        return localization.rejected;
      case RequestStatus.APPROVED:
        return localization.approved;
    }
  }
}
