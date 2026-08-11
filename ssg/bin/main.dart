import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/constants.dart";
import "package:ssg/copy.dart";
import "package:ssg/log.dart";
import "package:ssg/projects_loading.dart";
import "package:uuid/uuid.dart";

import "pages/404.dart";
import "pages/blog.dart";
import "pages/home.dart";
import "pages/project_tags.dart";

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty && arguments[0] == "new-blog-post") {
    final filename = arguments[1]
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]"), " ")
        .trim()
        .replaceAll(RegExp(r"\s+"), "-");
    if (arguments.length < 2 || filename.isEmpty) {
      log.severe("Provide the name of the new blog post");
      exit(1);
    }
    final now = DateTime.now();
    final dirNewPost = Directory(
      p.join(
        "blog",
        now.year.toStringDigits(4),
        now.month.toStringDigits(),
        now.day.toStringDigits(),
      ),
    )..createSync(recursive: true);
    final fileNewPost = File(p.join(dirNewPost.path, "$filename.md"));
    if (fileNewPost.existsSync()) {
      log.severe("File ${fileNewPost.path} already exists!");
      exit(1);
    }
    fileNewPost.writeAsStringSync("""
---
tags: [ ]
atom-id: "${const Uuid().v7()}"
---

# ${arguments[1].trim()}
""");
    log.info("Generated ${fileNewPost.path}");
    exit(0);
  }

  if (dirBuild.existsSync()) {
    dirBuild.deleteSync(recursive: true);
  }
  dirBuild.createSync();

  await setupProjectRepository();

  log.info("Starting generation...");

  copy("images", "images");
  copy("ssg/copy", "");
  copy("ssg/styles", "styles");

  await createHomePage();
  await createProjectsTagsPages();
  await createBlog();
  await create404();

  github.dispose();
  http.close();
  log.info("Done with generation!");
}
