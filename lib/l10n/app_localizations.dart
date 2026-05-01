import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get language;

  /// No description provided for @hiWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Hi, Welcome Back'**
  String get hiWelcomeBack;

  /// No description provided for @blah.
  ///
  /// In en, this message translates to:
  /// **'blah'**
  String get blah;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @bestSellersOf.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers Of {category}'**
  String bestSellersOf(Object category);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @myItems.
  ///
  /// In en, this message translates to:
  /// **'My Items'**
  String get myItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @pickImageFrom.
  ///
  /// In en, this message translates to:
  /// **'Pick an image from:'**
  String get pickImageFrom;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @camping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get camping;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @boats.
  ///
  /// In en, this message translates to:
  /// **'Boats'**
  String get boats;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @pleaseEnterYourDetailsToProceed.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Your Details To Proceed'**
  String get pleaseEnterYourDetailsToProceed;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get usernameOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @byContinuingYouAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to Terms of Use and Privacy Policy'**
  String get byContinuingYouAgreeToTerms;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @setLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get setLocation;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// No description provided for @usersReviews.
  ///
  /// In en, this message translates to:
  /// **'Users reviews'**
  String get usersReviews;

  /// No description provided for @rentItem.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rentItem;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @contactUserDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact User Details'**
  String get contactUserDetails;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @pleaseChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Please choose location'**
  String get pleaseChooseLocation;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @noChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChatsYet;

  /// No description provided for @errorLoadingSellerDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading seller details'**
  String get errorLoadingSellerDetails;

  /// No description provided for @errorLoadingItem.
  ///
  /// In en, this message translates to:
  /// **'Error loading item'**
  String get errorLoadingItem;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @orSearchByCategory.
  ///
  /// In en, this message translates to:
  /// **'Or search by category'**
  String get orSearchByCategory;

  /// No description provided for @theRequestSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The request sent successfully'**
  String get theRequestSentSuccessfully;

  /// No description provided for @myOrder.
  ///
  /// In en, this message translates to:
  /// **'My order'**
  String get myOrder;

  /// No description provided for @goBackToMainScreen.
  ///
  /// In en, this message translates to:
  /// **'Go back to the main screen'**
  String get goBackToMainScreen;

  /// No description provided for @trackYourRequest.
  ///
  /// In en, this message translates to:
  /// **'Track your request'**
  String get trackYourRequest;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get pendingRequests;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All the items'**
  String get allItems;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @noItemsToShow.
  ///
  /// In en, this message translates to:
  /// **'No items to show'**
  String get noItemsToShow;

  /// No description provided for @whatWouldYouLikeToSearch.
  ///
  /// In en, this message translates to:
  /// **'What would you like to search?'**
  String get whatWouldYouLikeToSearch;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @aroundYou.
  ///
  /// In en, this message translates to:
  /// **'Around you'**
  String get aroundYou;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location'**
  String get gettingLocation;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @peopleLikedTheItem.
  ///
  /// In en, this message translates to:
  /// **'people liked the item'**
  String get peopleLikedTheItem;

  /// No description provided for @peopleSeenTheItem.
  ///
  /// In en, this message translates to:
  /// **'people seen this item'**
  String get peopleSeenTheItem;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get show_more;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get addComment;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @no_permission.
  ///
  /// In en, this message translates to:
  /// **'No permission'**
  String get no_permission;

  /// No description provided for @location_services_are_turned_off.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off'**
  String get location_services_are_turned_off;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get please_wait;

  /// No description provided for @change_location.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get change_location;

  /// No description provided for @grant_permission.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get grant_permission;

  /// No description provided for @open_location_settings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get open_location_settings;

  /// No description provided for @show_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Show my phone number'**
  String get show_phone_number;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @approved_by_the_owner.
  ///
  /// In en, this message translates to:
  /// **'Approved by the owner'**
  String get approved_by_the_owner;

  /// No description provided for @rejected_by_the_owner.
  ///
  /// In en, this message translates to:
  /// **'Rejected by the owner'**
  String get rejected_by_the_owner;

  /// No description provided for @approved_by_the_applicant.
  ///
  /// In en, this message translates to:
  /// **'Approved by the applicant'**
  String get approved_by_the_applicant;

  /// No description provided for @rejected_by_the_applicant.
  ///
  /// In en, this message translates to:
  /// **'Rejected by the applicant'**
  String get rejected_by_the_applicant;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @my_requests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get my_requests;

  /// No description provided for @requested_from_me.
  ///
  /// In en, this message translates to:
  /// **'Requested from me'**
  String get requested_from_me;

  /// No description provided for @waiting_requests.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting_requests;

  /// No description provided for @require_attention_requests.
  ///
  /// In en, this message translates to:
  /// **'Require Attention'**
  String get require_attention_requests;

  /// No description provided for @processed_requests.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processed_requests;

  /// No description provided for @rentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get rentals;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @punctuality.
  ///
  /// In en, this message translates to:
  /// **'Punctuality'**
  String get punctuality;

  /// No description provided for @itemsOf.
  ///
  /// In en, this message translates to:
  /// **'Items of {name}'**
  String itemsOf(String name);

  /// No description provided for @lastSeenTodayAtTime.
  ///
  /// In en, this message translates to:
  /// **'Last seen today at {time}'**
  String lastSeenTodayAtTime(String time);

  /// No description provided for @lastSeenYesterdayAtTime.
  ///
  /// In en, this message translates to:
  /// **'Last seen yesterday at {time}'**
  String lastSeenYesterdayAtTime(String time);

  /// No description provided for @lastSeenOnDateAtTime.
  ///
  /// In en, this message translates to:
  /// **'Last seen on {date} at {time}'**
  String lastSeenOnDateAtTime(String date, String time);

  /// X meters from you
  ///
  /// In en, this message translates to:
  /// **'{meters} meters from you'**
  String metersFromYou(String meters);

  /// X km from you
  ///
  /// In en, this message translates to:
  /// **'{km} km from you'**
  String kmFromYou(String km);

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'{index} out of {total}'**
  String outOf(int index, int total);

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @conditionUsedAsNew.
  ///
  /// In en, this message translates to:
  /// **'Used as new'**
  String get conditionUsedAsNew;

  /// No description provided for @conditionUsedInGoodShape.
  ///
  /// In en, this message translates to:
  /// **'Used in good shape'**
  String get conditionUsedInGoodShape;

  /// No description provided for @conditionUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get conditionUsed;

  /// No description provided for @categoryTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get categoryTools;

  /// No description provided for @categorySport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get categorySport;

  /// No description provided for @categoryCamping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get categoryCamping;

  /// No description provided for @categoryKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get categoryKitchen;

  /// No description provided for @categorySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// No description provided for @categoryEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get categoryEvents;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get categoryGames;

  /// No description provided for @categoryPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get categoryPets;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @rentalHistory.
  ///
  /// In en, this message translates to:
  /// **'Rental History'**
  String get rentalHistory;

  /// No description provided for @theSelectedDateRangeIsInvalid.
  ///
  /// In en, this message translates to:
  /// **'The selected date range is invalid'**
  String get theSelectedDateRangeIsInvalid;

  /// No description provided for @theDateRangeContainsAnUnavailableDate.
  ///
  /// In en, this message translates to:
  /// **'The date range contains an unavailable date. Please select different dates'**
  String get theDateRangeContainsAnUnavailableDate;

  /// No description provided for @emptyItems.
  ///
  /// In en, this message translates to:
  /// **'You haven’t added any items to your store yet!\nClick Add Item and upload your first items'**
  String get emptyItems;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'There are no pending requests at the moment'**
  String get noPendingRequests;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'he': return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
