import "dart:io";

import "package:github/github.dart";
import "package:path/path.dart" as p;
import "package:ssg/html.dart";

import "body.dart";
import "head.dart";
import "log.dart";
import "projects.dart";

final GitHub github = GitHub(auth: findAuthenticationFromEnvironment());

Future<void> main(List<String> arguments) async {
  await setupProjectRepository();

  log.info("Starting generation...");
  final String html = HTML(
    lang: "en",
    head: generateHead(),
    body: generateBody(),
  ).build();

  final Directory build = Directory("build")..createSync();

  final Directory copy = Directory("ssg/copy");
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

  github.dispose();
  log.info("Done with generation!");
}
