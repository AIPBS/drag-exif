/// Read-only BMP tags — ExifTool "Writable = no" entries for the BMP group.
const Set<String> bmpReadOnlyTags = {
  'BMPVersion',
  'ImageWidth',
  'ImageHeight',
  'Planes',
  'BitDepth',
  'Compression',
  'ImageLength',
  'PixelsPerMeterX',
  'PixelsPerMeterY',
  'NumColors',
  'NumImportantColors',
};
