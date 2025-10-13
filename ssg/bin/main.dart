import "dart:io";

import "package:bindings_html/html.dart";
import "package:path/path.dart" as p;

import "body.dart";
import "head.dart";

void main(List<String> arguments) {
  final String html = HTML(
    lang: "en",
    head: generateHead(),
    body: generateBody(),
  ).build();

  final Directory build = Directory("build")..createSync();

  final Directory copy = Directory("copy");
  for (final FileSystemEntity fse in copy.listSync()) {
    if (fse is File) {
      fse.copySync(p.join(build.path, p.basename(fse.path)));
    }
  }

  final Directory images = Directory("images");
  Directory(p.join(build.path, images.path)).createSync();
  for (final FileSystemEntity fse in images.listSync()) {
    if (fse is File) {
      fse.copySync(p.join(build.path, fse.path));
    }
  }

  File(p.join(build.path, "index.html")).writeAsStringSync(html);
}
