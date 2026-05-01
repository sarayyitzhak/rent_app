import 'package:rent_app/l10n/app_localizations.dart';


enum RequestStatus{
  waiting,
  ownerApproved,
  ownerRejected,
  applicantApproved,
  applicantRejected,
  expired,
}

RequestStatus getRequestStatusByIndex(int idx){
  return RequestStatus.values[idx];
}


extension RequestStatusExtension on RequestStatus {
  String getTitle(AppLocalizations localization) {
    switch (this) {
      case RequestStatus.waiting:
        return localization.waiting;
      case RequestStatus.ownerRejected:
        return localization.rejected_by_the_owner;
      case RequestStatus.ownerApproved:
        return localization.approved_by_the_owner;
      case RequestStatus.applicantRejected:
        return localization.rejected_by_the_applicant;
      case RequestStatus.applicantApproved:
        return localization.approved_by_the_applicant;
      case RequestStatus.expired:
        return localization.expired;
    }
  }
}
