import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";

final Directory dirBlog = Directory("blog");
final Directory dirBuildBlog = Directory(p.join("build", dirBlog.path))..createSync();

Future<void> createBlog() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(),
    body: await generateBody(),
  ).build();
  File(p.join(dirBuildBlog.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> generateBody() async {
  final List<ListItem> yearItems = [];

  final List<FileSystemEntity> years = dirBlog.listSync()..sortFSE();
  for (final Directory year in years.whereType<Directory>()) {
    final String yearName = p.basenameWithoutExtension(year.path);
    final List<ListItem> monthItems = [];

    final List<FileSystemEntity> months = year.listSync()..sortFSE();
    for (final Directory month in months.whereType<Directory>()) {
      final int monthIndex = int.parse(p.basenameWithoutExtension(month.path));
      final String monthName = monthNames[monthIndex - 1];
      final List<ListItem> dayItems = [];

      final List<FileSystemEntity> days = month.listSync()..sortFSE();
      for (final Directory day in days.whereType<Directory>()) {
        final String dayName = p.basenameWithoutExtension(day.path);
        final List<ListItem> postItems = [];

        final List<FileSystemEntity> posts = day.listSync()..sortFSE();
        for (final File post in posts.whereType<File>()) {
          final String title = await _generateBlogPost(post);
          postItems.add(
            ListItem(
              children: [
                A.text(title, href: postPath(post)),
              ],
            ),
          );
        }
        dayItems.add(
          ListItem(
            value: dayName,
            children: [
              UnorderedList(items: postItems, classes: ["posts"]),
            ],
          ),
        );
      }
      monthItems.add(
        ListItem(
          value: monthIndex.toString(),
          children: [
            T(monthName),
            OrderedList(items: dayItems, classes: ["days"]),
          ],
        ),
      );
    }
    yearItems.add(
      ListItem(
        value: yearName,
        children: [
          OrderedList(items: monthItems, classes: ["months"]),
        ],
      ),
    );
  }

  return Body(
    header: generateHeader(filename: "Blog", showBlog: false),
    main: Main(
      children: [
        H1.text("Blog"),
        P.text("This is my blog"),
        OrderedList(items: yearItems, classes: ["years"]),
      ],
    ),
    footer: generateFooter(),
  );
}

String postPath(File post) => p.withoutExtension(p.relative(post.path, from: dirBlog.path));

/// Returns the title of the blog post (contents of the first H1)
Future<String> _generateBlogPost(File post) async {
  final String path = postPath(post);

  final mdElements = markdown(await post.readAsString());
  final H1? h1 = mdElements.whereType<H1>().firstOrNull;
  if (h1 == null) {
    throw Exception("Post `$path` does not have a title (an H1)!");
  }

  final postDir = Directory(p.join(dirBuildBlog.path, path))..createSync(recursive: true);
  final postHtml = File(p.join(postDir.path, "index.html"));

  await postHtml.writeAsString(Div(children: mdElements).build());

  return h1.innerText;
}
