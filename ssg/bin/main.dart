import "dart:io";

import "package:github/github.dart";
import "package:glob/glob.dart";
import "package:glob/list_local_fs.dart";
import "package:path/path.dart" as p;

import "log.dart";
import "pages/home.dart";
import "pages/tags.dart";
import "projects_loading.dart";

final GitHub github = GitHub(auth: findAuthenticationFromEnvironment());
final Directory dirBuild = Directory("build")..createSync();

Future<void> main(List<String> arguments) async {
  await setupProjectRepository();

  log.info("Starting generation...");

  copy("images", "images");
  copy("ssg/copy/**", "");
  copy("ssg/styles", "styles");

  createHomePage();
  createTagsPages();

  github.dispose();
  log.info("Done with generation!");
}

void copy(String source, String targetInBuild) {
  final Glob sourceGlob = Glob(source);
  final targetDir = Directory(p.joinAll([dirBuild.path, ...targetInBuild.split("/")]))..createSync();
  for (final FileSystemEntity fse in sourceGlob.listSync()) {
    switch (fse) {
      case File():
        fse.copySync(p.join(targetDir.path, p.basename(fse.path)));
      case Directory():
        for (final FileSystemEntity fse2 in fse.listSync()) {
          switch (fse2) {
            case File():
              fse2.copySync(p.join(targetDir.path, p.basename(fse2.path)));
            case Directory():
              copy(fse2.path, p.joinAll([...targetInBuild.split("/"), p.relative(fse2.path, from: source)]));
          }
        }
    }
  }
}
