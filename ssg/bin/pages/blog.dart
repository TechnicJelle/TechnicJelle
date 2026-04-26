import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/atom/generate.dart";
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:ssg/log.dart";
import "package:ssg/md_file.dart";
import "package:techs_html_bindings/elements.dart";

final Directory dirBlog = Directory("blog");
final Directory dirBuildBlog = Directory(p.join("build", dirBlog.path))..createSync();

//TODO: Implement article tags
//TODO: Maybe also have a feed per blog tag? But only show those if you actually go to that tag page and search for linked feeds.

Future<void> createBlog() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(extraStyles: ["blog"]),
    body: await generateBody(),
  ).build();
  File(p.join(dirBuildBlog.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> generateBody() async {
  final List<MdFile> mdFiles = [];
  final List<Element> yearItems = [];

  final List<Directory> years = dirBlog.listSync().dirs()..sortFSE();
  for (final Directory year in years.reversed) {
    final String yearName = p.basenameWithoutExtension(year.path);
    final List<Element> monthItems = [];

    final List<Directory> months = year.listSync().dirs()..sortFSE();
    for (final Directory month in months.reversed) {
      final int monthIndex = int.parse(p.basenameWithoutExtension(month.path));
      final String monthName = monthNames[monthIndex - 1];
      final List<Element> dayItems = [];

      final List<Directory> days = month.listSync().dirs()..sortFSE();
      for (final Directory day in days.reversed) {
        final String dayName = p.basenameWithoutExtension(day.path);
        final List<ListItem> postItems = [];

        final List<File> posts = day.listSync().files()..sortFSE();
        for (final File post in posts) {
          final mdFile = await _generateBlogPost(post);
          final String path = "/${p.join(dirBlog.path, postPath(post))}";

          final String? title = mdFile.title;
          if (title == null) throw Exception("Post `$path` does not have a title (an H1)!");
          postItems.add(ListItem(children: [A.text(title, href: path)]));
          mdFiles.add(mdFile);
          log.info("Found blog post $path");
        }
        dayItems
          ..add(H4.text(dayName, id: "$yearName-${monthIndex.toStringDigits()}-$dayName"))
          ..add(UnorderedList(items: postItems));
        generateBreadcrumbIndex(
          [yearName, monthIndex.toStringDigits(), dayName],
          [UnorderedList(items: postItems)],
        );
      }
      monthItems
        ..add(H3(children: [Span.text("$monthIndex"), T(monthName)], id: "$yearName-$monthIndex"))
        ..addAll(dayItems);
      generateBreadcrumbIndex([yearName, monthIndex.toStringDigits()], dayItems);
    }
    yearItems
      ..add(H2.text(yearName, id: yearName))
      ..addAll(monthItems);

    generateBreadcrumbIndex([yearName], monthItems);
  }

  final String blogUrl = "$baseUrl/${dirBlog.path}";
  await generateAtomFeed(
    destinationPath: dirBlog,
    title: "TechnicJelle's Blog",
    subtitle:
        "This is the Atom feed of TechnicJelle's blog. Here you will find articles I've written about things I've made, which can be games, art or something else entirely.",
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
        P.text(
          "This is my (TechnicJelle) blog! On this blog I write about things I make, which can be games, art or something else entirely",
        ),
        ...yearItems,
      ],
    ),
    footer: generateFooter(),
  );
}

void generateBreadcrumbIndex(List<String> path, List<Element> elements) {
  String aggregate = "/${dirBlog.path}";
  File(p.joinAll([dirBuildBlog.path, ...path, "index.html"])).writeAsStringSync(
    HTML(
      lang: "en",
      head: generateHead(extraStyles: ["blog"]),
      body: Body(
        header: generateHeader(
          breadcrumbs: [
            A.text("Blog", href: aggregate),
            ...path.map((String e) => A.text(e, href: aggregate += "/$e")).toList()..removeLast(),
          ],
          filename: path.last,
          showBlog: false,
        ),
        main: Main(
          children: [
            H1.text(path.last),
            ...elements,
          ],
        ),
        footer: generateFooter(),
      ),
    ).build(),
  );
}

String postPath(File post) => p.withoutExtension(p.relative(post.path, from: dirBlog.path));

/// Returns the title of the blog post (contents of the first H1)
Future<MdFile> _generateBlogPost(File post) async {
  final MdFile mdFile = MdFile(file: post);

  final String path = postPath(post);
  final postDir = Directory(p.join(dirBuildBlog.path, path))..createSync(recursive: true);
  final postHtml = File(p.join(postDir.path, "index.html"));

  final List<String> parts = p.split(mdFile.file.path).toList()..removeAt(0);
  if (parts.length != 4) throw Exception("Could not extract date from mdFile path!?");

  String aggregate = "/${dirBlog.path}";
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(),
    body: Body(
      header: generateHeader(
        breadcrumbs: [
          A.text("Blog", href: aggregate),
          ...parts.map((String e) => A.text(e, href: aggregate += "/$e")).toList()..removeLast(),
        ],
        filename: parts.last,
        showBlog: false,
      ),
      main: Main(
        children: mdFile.elements,
      ),
      footer: generateFooter(),
    ),
  ).build();

  await postHtml.writeAsString(indexHTML);

  return mdFile;
}
