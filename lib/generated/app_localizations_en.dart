// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get appTitle => 'DragExif';

  @override
  String get appSubtitle => 'EXIF metadata viewer';

  @override
  String get windowTitle => 'DragExif v1.0.0';

  @override
  String windowTitleWithCount(Object count) {
    return 'DragExif v1.0.0 - $count files';
  }

  @override
  String get menu => 'Menu';

  @override
  String get menuSettings => 'Settings…';

  @override
  String get menuAbout => 'About…';

  @override
  String get menuExit => 'Exit';

  @override
  String get openFiles => 'Open files…';

  @override
  String get copy => 'Copy';

  @override
  String get addTag => 'Add tag';

  @override
  String get save => 'Save';

  @override
  String get discard => 'Discard';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String unsavedChangesBanner(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fields',
      one: 'field',
    );
    return 'Unsaved changes ($count $_temp0)';
  }

  @override
  String get unsavedChangesDialogTitle => 'Unsaved Changes';

  @override
  String unsavedChangesDialogContent(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'changes',
      one: 'change',
    );
    return 'You have $count unsaved $_temp0. Do you want to save them before continuing?';
  }

  @override
  String get changesSaved => 'Changes saved';

  @override
  String saveFailed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String cannotAddReadOnlyTag(Object group, Object tagName) {
    return 'Cannot add read-only tag: $tagName ($group)';
  }

  @override
  String get dropFilesHint => 'Drop image files or click \"Open files…\"';

  @override
  String get selectFileHint => 'Select a file to view EXIF data';

  @override
  String get noExifData => 'No EXIF data for selected files';

  @override
  String get preview => 'Preview';

  @override
  String get noPreview => 'No preview';

  @override
  String get cannotLoadImage => 'Cannot load image';

  @override
  String get previewNotAvailable => 'Preview not available';

  @override
  String get settings => 'Settings';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System setting';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get alwaysOnTop => 'Keep window always on top';

  @override
  String get exifToolPath => 'Executable Path';

  @override
  String get exifToolPathSelect => 'Select…';

  @override
  String get exifToolArguments => 'Arguments';

  @override
  String get previewSettings => 'Preview';

  @override
  String get about => 'About';

  @override
  String version(Object version) {
    return 'Version: $version';
  }

  @override
  String get copyright => 'Copyright © 2026 by Allen';

  @override
  String get allRightsReserved => 'All rights reserved.';

  @override
  String get credits => 'Credits';

  @override
  String get creditExifTool => 'ExifTool';

  @override
  String get creditExifToolLicense =>
      'Distributed under the terms of the Artistic license.\nCopyright © Phil Harvey.';

  @override
  String get creditFlutter => 'Flutter';

  @override
  String get creditFlutterLicense =>
      'Distributed under the terms of the BSD license.\nCopyright © Google LLC.';

  @override
  String get addTagDialogTitle => 'Add EXIF Tag';

  @override
  String get addTagDialogSearchHint =>
      'Type to search tags (e.g. Date, GPS, Lens...)';

  @override
  String get addTagDialogCustomNameHint => 'Enter custom tag name';

  @override
  String get addTagDialogValueHint => 'Enter tag value';

  @override
  String get addTagDialogNoMatchingTags => 'No matching tags';

  @override
  String get addTagDialogCustomTag => 'Custom tag';

  @override
  String addTagDialogTagLabel(Object group, Object tagName) {
    return 'Tag: $tagName ($group)';
  }

  @override
  String addTagDialogTagsAvailable(Object count) {
    return '$count tags available';
  }

  @override
  String tagCount(Object count) {
    return '$count tags';
  }

  @override
  String get cannotBeEdited => 'Cannot be edited';

  @override
  String get exportAs => 'Export as…';

  @override
  String get exportText => 'Text file…';

  @override
  String get exportCsv => 'CSV file…';

  @override
  String get exportJson => 'JSON file…';

  @override
  String get filePickerImages => 'Images';

  @override
  String fileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'files',
      one: 'file',
    );
    return '$count $_temp0';
  }

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get columnTagId => 'Tag ID';

  @override
  String get columnTagName => 'Tag Name';

  @override
  String get columnValue => 'Value';

  @override
  String get appTheme => 'App Theme';

  @override
  String get exifToolConfigurations => 'ExifTool Configurations';

  @override
  String get exifToolBinary => 'ExifTool binary';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文 (Chinese)';
}
