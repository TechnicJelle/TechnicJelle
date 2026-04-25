import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/constants.dart";
import "package:ssg/copy.dart";
import "package:ssg/log.dart";
import "package:ssg/projects_loading.dart";
import "package:uuid/uuid.dart";

import "pages/blog.dart";
import "pages/home.dart";
import "pages/tags.dart";

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty && arguments[0] == "new-blog-post") {
    if (arguments.length < 2 || arguments[1].isEmpty) {
      log.severe("Provide the name of the new blog post");
      exit(1);
    }
    final now = DateTime.now();
    final dirNewPost = Directory(
      p.join(
        "blog",
        now.year.toString()..padLeft(4, "0"),
        now.month.toString().padLeft(2, "0"),
        now.day.toString().padLeft(2, "0"),
      ),
    )..createSync(recursive: true);
    final fileNewPost = File(p.join(dirNewPost.path, "${arguments[1]}.md"));
    if (fileNewPost.existsSync()) {
      log.severe("File ${fileNewPost.path} already exists!");
      exit(1);
    }
    fileNewPost.writeAsStringSync("""
---
tags: [ ]
atom-id: "${const Uuid().v7()}"
---

# ${arguments[1]}
""");
    log.info("Generated ${fileNewPost.path}");
    exit(0);
  }

  await setupProjectRepository();

  log.info("Starting generation...");

  copy("images", "images");
  copy("ssg/copy", "");
  copy("ssg/styles", "styles");

  await createHomePage();
  await createTagsPages();
  await createBlog();

  github.dispose();
  http.close();
  log.info("Done with generation!");
}
