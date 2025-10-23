import "package:ssg/constants.dart";
import "package:ssg/copy.dart";
import "package:ssg/log.dart";
import "package:ssg/projects_loading.dart";

import "pages/home.dart";
import "pages/tags.dart";

Future<void> main(List<String> arguments) async {
  await setupProjectRepository();

  log.info("Starting generation...");

  copy("images", "images");
  copy("ssg/copy", "");
  copy("ssg/styles", "styles");

  createHomePage();
  createTagsPages();

  github.dispose();
  log.info("Done with generation!");
}
