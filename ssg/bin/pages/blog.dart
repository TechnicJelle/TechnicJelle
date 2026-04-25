import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/atom/generate.dart";
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:ssg/md_file.dart";
import "package:techs_html_bindings/elements.dart";

final Directory dirBlog = Directory("blog");
final Directory dirBuildBlog = Directory(p.join("build", dirBlog.path))..createSync();

//TODO: Implement article tags
//TODO: Maybe also have a feed per blog tag? But only show those if you actually go to that tag page and search for linked feeds.

Future<void> createBlog() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(),
    body: await generateBody(),
  ).build();
  File(p.join(dirBuildBlog.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> generateBody() async {
  final List<MdFile> mdFiles = [];
  final List<ListItem> yearItems = [];

  //TODO: Make index.html files for all the intermediate directories, like the year, month, and day; all linking to their sub-things.
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
          final mdFile = await _generateBlogPost(post);
          final String path = postPath(post);

          final String? title = mdFile.title;
          if (title == null) throw Exception("Post `$path` does not have a title (an H1)!");
          postItems.add(
            ListItem(
              children: [
                A.text(title, href: path),
              ],
            ),
          );
          mdFiles.add(mdFile);
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

  const String blogUrl = "$baseUrl/blog";
  await generateAtomFeed(
    destinationPath: dirBlog,
    title: "TechnicJelle's Blog",
    subtitle:
        "This is the Atom feed of TechnicJelle's blog. Here you will find articles I've written about things I did.",
    author: "TechnicJelle",
    siteRootUrl: baseUrl,
    entries: mdFiles.map((f) => f.toAtomEntry("$blogUrl/${postPath(f.file)}")).toList(growable: false),
    //never change this:
    id: "urn:uuid:019dc1b3-1427-7fbf-b058-015b535012e1",
  );

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
Future<MdFile> _generateBlogPost(File post) async {
  final MdFile mdFile = MdFile(file: post);

  final String path = postPath(post);
  final postDir = Directory(p.join(dirBuildBlog.path, path))..createSync(recursive: true);
  final postHtml = File(p.join(postDir.path, "index.html"));

  await postHtml.writeAsString(Div(children: mdFile.elements).build());

  return mdFile;
}
