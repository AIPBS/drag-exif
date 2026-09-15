import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Drag Exif'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'EXIF metadata viewer'**
  String get appSubtitle;

  /// No description provided for @windowTitle.
  ///
  /// In en, this message translates to:
  /// **'Drag Exif v1.1.1'**
  String get windowTitle;

  /// No description provided for @windowTitleWithCount.
  ///
  /// In en, this message translates to:
  /// **'Drag Exif v1.1.1 - {count} files'**
  String windowTitleWithCount(Object count);

  /// No description provided for @openFiles.
  ///
  /// In en, this message translates to:
  /// **'Open files…'**
  String get openFiles;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unsavedChangesBanner.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes ({count} {count, plural, =1 {field} other {fields}})'**
  String unsavedChangesBanner(num count);

  /// No description provided for @unsavedChangesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesDialogTitle;

  /// No description provided for @unsavedChangesDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unsaved {count, plural, =1 {change} other {changes}}. Do you want to save them before continuing?'**
  String unsavedChangesDialogContent(num count);

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(Object error);

  /// No description provided for @cannotAddReadOnlyTag.
  ///
  /// In en, this message translates to:
  /// **'Cannot add read-only tag: {tagName} ({group})'**
  String cannotAddReadOnlyTag(Object group, Object tagName);

  /// No description provided for @dropFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Drop image files or click \"Open files…\"'**
  String get dropFilesHint;

  /// No description provided for @selectFileHint.
  ///
  /// In en, this message translates to:
  /// **'Select a file to view EXIF data'**
  String get selectFileHint;

  /// No description provided for @noExifData.
  ///
  /// In en, this message translates to:
  /// **'No EXIF data for selected files'**
  String get noExifData;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @noPreview.
  ///
  /// In en, this message translates to:
  /// **'No preview'**
  String get noPreview;

  /// No description provided for @cannotLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Cannot load image'**
  String get cannotLoadImage;

  /// No description provided for @previewNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Preview not available'**
  String get previewNotAvailable;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System setting'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @alwaysOnTop.
  ///
  /// In en, this message translates to:
  /// **'Keep window always on top'**
  String get alwaysOnTop;

  /// No description provided for @exifToolPath.
  ///
  /// In en, this message translates to:
  /// **'Executable Path'**
  String get exifToolPath;

  /// No description provided for @exifToolPathSelect.
  ///
  /// In en, this message translates to:
  /// **'Select…'**
  String get exifToolPathSelect;

  /// No description provided for @exifToolArguments.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get exifToolArguments;

  /// No description provided for @previewSettings.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSettings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(Object version);

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2026 by Allen'**
  String get copyright;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved.'**
  String get allRightsReserved;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @creditExifTool.
  ///
  /// In en, this message translates to:
  /// **'ExifTool'**
  String get creditExifTool;

  /// No description provided for @creditExifToolLicense.
  ///
  /// In en, this message translates to:
  /// **'Distributed under the terms of the Artistic license.\nCopyright © Phil Harvey.'**
  String get creditExifToolLicense;

  /// No description provided for @creditFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get creditFlutter;

  /// No description provided for @creditFlutterLicense.
  ///
  /// In en, this message translates to:
  /// **'Distributed under the terms of the BSD license.\nCopyright © Google LLC.'**
  String get creditFlutterLicense;

  /// No description provided for @addTagDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add EXIF Tag'**
  String get addTagDialogTitle;

  /// No description provided for @addTagDialogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type to search tags (e.g. Date, GPS, Lens...)'**
  String get addTagDialogSearchHint;

  /// No description provided for @addTagDialogCustomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter custom tag name'**
  String get addTagDialogCustomNameHint;

  /// No description provided for @addTagDialogValueHint.
  ///
  /// In en, this message translates to:
  /// **'Enter tag value'**
  String get addTagDialogValueHint;

  /// No description provided for @addTagDialogNoMatchingTags.
  ///
  /// In en, this message translates to:
  /// **'No matching tags'**
  String get addTagDialogNoMatchingTags;

  /// No description provided for @addTagDialogCustomTag.
  ///
  /// In en, this message translates to:
  /// **'Custom tag'**
  String get addTagDialogCustomTag;

  /// No description provided for @addTagDialogTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag: {tagName} ({group})'**
  String addTagDialogTagLabel(Object group, Object tagName);

  /// No description provided for @addTagDialogTagsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} tags available'**
  String addTagDialogTagsAvailable(Object count);

  /// No description provided for @tagCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tags'**
  String tagCount(Object count);

  /// No description provided for @cannotBeEdited.
  ///
  /// In en, this message translates to:
  /// **'Cannot be edited'**
  String get cannotBeEdited;

  /// No description provided for @exportAs.
  ///
  /// In en, this message translates to:
  /// **'Export as…'**
  String get exportAs;

  /// No description provided for @exportText.
  ///
  /// In en, this message translates to:
  /// **'Text file…'**
  String get exportText;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV file…'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'JSON file…'**
  String get exportJson;

  /// No description provided for @filePickerImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get filePickerImages;

  /// No description provided for @fileCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1 {file} other {files}}'**
  String fileCount(num count);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(Object count);

  /// No description provided for @columnTagId.
  ///
  /// In en, this message translates to:
  /// **'Tag ID'**
  String get columnTagId;

  /// No description provided for @columnTagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get columnTagName;

  /// No description provided for @columnValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get columnValue;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @exifToolConfigurations.
  ///
  /// In en, this message translates to:
  /// **'ExifTool Configurations'**
  String get exifToolConfigurations;

  /// No description provided for @exifToolBinary.
  ///
  /// In en, this message translates to:
  /// **'ExifTool binary'**
  String get exifToolBinary;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文 (Chinese)'**
  String get languageChinese;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
