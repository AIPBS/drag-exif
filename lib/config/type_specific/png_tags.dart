/// Read-only PNG tags — ExifTool "Writable = no" entries for the PNG group.
/// Curated manually from ExifTool tag tables.
const Set<String> pngReadOnlyTags = {
  'Bit Depth',
  'Color Type',
  'Compression',
  'Filter',
  'Interlace',
  'Image Height',
  'Image Width',
  // Add more as you discover them (e.g. IHDR-derived structural chunks)
};
