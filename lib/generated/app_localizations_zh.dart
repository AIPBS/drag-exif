// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '图像 EXIF 编辑器';

  @override
  String get appSubtitle => 'EXIF 元数据查看器';

  @override
  String get windowTitle => '图像 EXIF 编辑器 v1.0.0';

  @override
  String windowTitleWithCount(Object count) {
    return '图像 EXIF 编辑器 v1.0.0 - $count 个文件';
  }

  @override
  String get menu => '菜单';

  @override
  String get menuSettings => '设置…';

  @override
  String get menuAbout => '关于…';

  @override
  String get menuExit => '退出';

  @override
  String get openFiles => '打开文件…';

  @override
  String get copy => '复制';

  @override
  String get addTag => '添加标签';

  @override
  String get save => '保存';

  @override
  String get discard => '放弃';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get close => '关闭';

  @override
  String unsavedChangesBanner(num count) {
    return '未保存的更改 ($count 个字段)';
  }

  @override
  String get unsavedChangesDialogTitle => '未保存的更改';

  @override
  String unsavedChangesDialogContent(num count) {
    return '您有 $count 个未保存的更改。您想在继续之前保存它们吗？';
  }

  @override
  String get changesSaved => '更改已保存';

  @override
  String saveFailed(Object error) {
    return '保存失败：$error';
  }

  @override
  String cannotAddReadOnlyTag(Object group, Object tagName) {
    return '无法添加只读标签：$tagName ($group)';
  }

  @override
  String get dropFilesHint => '拖放图像文件或点击\"打开文件…\"';

  @override
  String get selectFileHint => '选择文件以查看 EXIF 数据';

  @override
  String get noExifData => '所选文件没有 EXIF 数据';

  @override
  String get preview => '预览';

  @override
  String get noPreview => '无预览';

  @override
  String get cannotLoadImage => '无法加载图像';

  @override
  String get previewNotAvailable => '预览不可用';

  @override
  String get settings => '设置';

  @override
  String get themeMode => '主题';

  @override
  String get themeSystem => '系统设置';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get alwaysOnTop => '保持窗口置顶';

  @override
  String get exifToolPath => '可执行文件路径';

  @override
  String get exifToolPathSelect => '选择…';

  @override
  String get exifToolArguments => '参数';

  @override
  String get previewSettings => '预览';

  @override
  String get about => '关于';

  @override
  String version(Object version) {
    return '版本：$version';
  }

  @override
  String get copyright => '版权所有 © 2026 Allen';

  @override
  String get allRightsReserved => '保留所有权利。';

  @override
  String get credits => '致谢';

  @override
  String get creditExifTool => 'ExifTool';

  @override
  String get creditExifToolLicense =>
      '根据 Artistic 许可证条款分发。\n版权所有 © Phil Harvey。';

  @override
  String get creditFlutter => 'Flutter';

  @override
  String get creditFlutterLicense => '根据 BSD 许可证条款分发。\n版权所有 © Google LLC。';

  @override
  String get addTagDialogTitle => '添加 EXIF 标签';

  @override
  String get addTagDialogSearchHint => '输入搜索标签（例如：日期、GPS、镜头…）';

  @override
  String get addTagDialogCustomNameHint => '输入自定义标签名称';

  @override
  String get addTagDialogValueHint => '输入标签值';

  @override
  String get addTagDialogNoMatchingTags => '没有匹配的标签';

  @override
  String get addTagDialogCustomTag => '自定义标签';

  @override
  String addTagDialogTagLabel(Object group, Object tagName) {
    return '标签：$tagName ($group)';
  }

  @override
  String addTagDialogTagsAvailable(Object count) {
    return '$count 个标签可用';
  }

  @override
  String tagCount(Object count) {
    return '$count 个标签';
  }

  @override
  String get cannotBeEdited => '无法编辑';

  @override
  String get exportAs => '导出为…';

  @override
  String get exportText => '文本文件…';

  @override
  String get exportCsv => 'CSV 文件…';

  @override
  String get exportJson => 'JSON 文件…';

  @override
  String get filePickerImages => '图像';

  @override
  String fileCount(num count) {
    return '$count 个文件';
  }

  @override
  String selectedCount(Object count) {
    return '已选择 $count 个';
  }

  @override
  String get columnTagId => '标签 ID';

  @override
  String get columnTagName => '标签名称';

  @override
  String get columnValue => '值';

  @override
  String get appTheme => '应用主题';

  @override
  String get exifToolConfigurations => 'ExifTool 配置';

  @override
  String get exifToolBinary => 'ExifTool 可执行文件';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '系统默认';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';
}
