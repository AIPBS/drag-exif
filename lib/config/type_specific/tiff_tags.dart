/// Read-only TIFF tags — ExifTool "Writable = no" structural entries.
/// These are baseline/deeply-structural tags that ExifTool marks as non-writable.
const Set<String> tiffReadOnlyTags = {
  'ImageWidth',
  'ImageHeight',
  'BitsPerSample',
  'Compression',
  'PhotometricInterpretation',
  'StripOffsets',
  'SamplesPerPixel',
  'RowsPerStrip',
  'StripByteCounts',
  'TileWidth',
  'TileLength',
  'TileOffsets',
  'TileByteCounts',
  'PlanarConfiguration',
};
