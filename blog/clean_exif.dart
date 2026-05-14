#!/usr/bin/env dart
// dart format width=120

import "dart:async";
import "dart:io" as io;
import "dart:io";

final List<String> supportedFileTypes = ["mp4", "mkv", "png", "jpg", "jpeg", "jfif", "gif", "webp", "webm"];

extension P on FileSystemEntity {
  String get name => path.split(RegExp(r"[/\\]")).last;

  String get ext => path.split(".").last;
}

bool changesWereMade = false;

Future<void> main() async {
  final Directory cwd = Directory.current;
  final Directory dirBlog = Directory("${cwd.path}/blog");
  if (!dirBlog.existsSync()) exit(2);

  final List<File> files = dirBlog
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => supportedFileTypes.contains(f.ext.toLowerCase()))
      .toList();

  Iterable<Future> futures = files.map(runExifTool);
  await Future.wait(futures, eagerError: true);
  await io.stdout.flush();

  io.stdout.writeln("Done checking exif data on blog assets.");
  if (changesWereMade) {
    io.stdout.writeln("Changes were made that you should look over!");
    await io.stdout.flush();
    exit(1);
  }
  io.stdout.writeln("No changes were made.");
  await io.stdout.flush();
}

Future<void> runExifTool(File fileOriginal) async {
  final File fileClean = File("${fileOriginal.path}_clean");
  final ProcessResult prClean = await Process.run("exiftool", [
    // Preserve timestamps
    "-preserve",

    // Strip all metadata
    "-all=",

    // Copy back from the original file...
    ...["-tagsFromFile", "@"],

    // ...only these following tags:

    //most images have these
    "-XMP-x:XMPToolkit",
    "-XMP-x:ImageHeight",
    "-XMP-x:ImageWidth",
    //screenshots & blender image renders
    "-PNG-pHYs:all",
    //windows screenshot
    "-PNG:SRGBRendering",
    "-PNG:Gamma",
    //blender video renders
    "-QuickTime:HandlerType",
    "-QuickTime:HandlerVendorID",
    "-ItemList:Encoder",
    //phone camera photos (i like people knowing the specs of my camera)
    "-IFD0:YResolution",
    "-IFD0:XResolution",
    "-IFD0:ResolutionUnit",
    "-IFD0:ImageWidth",
    "-IFD0:ImageHeight",
    "-IFD0:Model",
    "-IFD0:Make",
    "-IFD0:YCbCrPositioning",
    "-IFD0:Orientation",
    "-ExifIFD:ApertureValue",
    "-ExifIFD:MaxApertureValue",
    "-ExifIFD:SceneType",
    "-ExifIFD:ExposureProgram",
    "-ExifIFD:ColorSpace",
    "-ExifIFD:ExifImageHeight",
    "-ExifIFD:ExifImageWidth",
    "-ExifIFD:BrightnessValue",
    "-ExifIFD:WhiteBalance",
    "-ExifIFD:ExposureMode",
    "-ExifIFD:ExposureTime",
    "-ExifIFD:Flash",
    "-ExifIFD:SubSecTime",
    "-ExifIFD:FNumber",
    "-ExifIFD:ISO",
    "-ExifIFD:ComponentsConfiguration",
    "-ExifIFD:FocalLengthIn35mmFormat",
    "-ExifIFD:DigitalZoomRatio",
    "-ExifIFD:ShutterSpeedValue",
    "-ExifIFD:MeteringMode",
    "-ExifIFD:FocalLength",
    "-ExifIFD:SceneCaptureType",
    "-ExifIFD:SensingMethod",
    "-ExifIFD:LightSource",
    "-ExifIFD:ExposureCompensation",
    "-ExifIFD:FlashpixVersion",
    "-ExifIFD:SubSecTimeOriginal",
    "-ExifIFD:SubSecTimeDigitized",
    "-IFD1:YResolution",
    "-IFD1:Compression",
    "-IFD1:XResolution",
    "-IFD1:Orientation",
    "-IFD1:ResolutionUnit",
    "-JFIF:ResolutionUnit",
    "-JFIF:XResolution",
    "-JFIF:YResolution",
    //phone camera videos
    "-Keys:AndroidVersion",
    "-Keys:AndroidMake",
    "-Keys:AndroidModel",
    fileOriginal.path,
    ...["-out", fileClean.path],
  ]);
  final String stderr = prClean.stderr.toString();
  if (stderr.contains(RegExp(r"Writing of \w+ files is not yet supported"))) return;
  if (prClean.exitCode != 0) {
    throw Exception("ExifTool failed with exitCode: ${prClean.exitCode}\n${prClean.stdout}\n${stderr}");
  }

  final ProcessResult prDiff = await Process.run("exiftool", [
    // Show the actual real tag names in the diff, not the pretty names (for easier copying into the code above)
    "-s",

    // Ignore the following tags in the diff:

    //system modification times and stuff
    "--System:all",
    //videos
    "--QuickTime:MediaDataOffset",
    "--ItemList:ContentCreateDate",
    //phone camera photos
    "--JFIF:JFIFVersion",
    "--ExifIFD:ExifVersion",
    "--IFD1:ThumbnailOffset",
    "--IFD1:ThumbnailLength",
    "--IFD1:ThumbnailImage",

    "-diff",
    fileOriginal.path,
    fileClean.path,
  ]);

  final String stdout = prDiff.stdout.toString();
  if (stdout.contains("no metadata differences")) {
    await fileClean.delete();
  } else {
    changesWereMade = true;
    io.stderr.writeln("ExifTool on `${fileOriginal.path}` removed the following tags:\n$stdout");
    final File fileOriginal2 = File("${fileOriginal.path}_original");
    await fileOriginal.rename(fileOriginal2.path);
    await fileClean.rename(fileOriginal.path);
  }
}
