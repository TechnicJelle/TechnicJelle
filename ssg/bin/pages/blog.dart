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
import "package:techs_html_bindings/utils.dart";

final Directory dirBlog = Directory("blog");
final Directory dirBuildBlog = Directory(p.join("build", dirBlog.path));

//TODO: Implement article tags
//TODO: Maybe also have a feed per blog tag? But only show those if you actually go to that tag page and search for linked feeds.

Future<void> createBlog() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(title: "Blog", extraStyles: ["blog-index"]),
    body: await generateBody(),
  ).build();
  File(p.join(dirBuildBlog.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> generateBody() async {
  final List<BlogPost> blogPosts = [];

  final List<Directory> years = dirBlog.listSync().dirs()..sortFSE();
  for (final Directory year in years) {
    final int yearIndex = int.parse(p.basenameWithoutExtension(year.path));
    final String yearName = yearIndex.toStringDigits(4);
    final List<Element> itemsInYear = [];

    final List<Directory> months = year.listSync().dirs()..sortFSE();
    for (final Directory month in months) {
      final int monthIndex = int.parse(p.basenameWithoutExtension(month.path));
      final String monthName = monthNames[monthIndex - 1];
      final List<Element> itemsInMonth = [];

      final List<Directory> days = month.listSync().dirs()..sortFSE();
      for (final Directory day in days) {
        final int dayIndex = int.parse(p.basenameWithoutExtension(day.path));
        final String dayName = dayIndex.toStringDigits();
        final List<Element> itemsOnDay = [];

        final List<File> posts = day.listSync().where((fse) => fse.path.endsWith(".md")).files()..sortFSE();
        for (final File post in posts) {
          final postFile = BlogPost(file: post, year: yearIndex, month: monthIndex, day: dayIndex);
          itemsOnDay.add(postFile.generateCard());
          blogPosts.add(postFile);
        }
        itemsInMonth.addAll(itemsOnDay);
        generateBreadcrumbIndex(
          h1Text: "$dayIndex $monthName $yearName",
          path: [yearName, monthIndex.toStringDigits(), dayName],
          elements: itemsOnDay,
        );
      }
      itemsInYear.addAll(itemsInMonth);
      generateBreadcrumbIndex(
        h1Text: "$monthName $yearName",
        path: [yearName, monthIndex.toStringDigits()],
        elements: itemsInMonth,
      );
    }
    generateBreadcrumbIndex(
      h1Text: yearName,
      path: [yearName],
      elements: itemsInYear,
    );
  }

  final String blogUrl = "$baseUrl/${dirBlog.path}";
  await generateAtomFeed(
    destinationPath: dirBlog,
    title: "TechnicJelle's Blog",
    subtitle:
        "This is the Atom feed of TechnicJelle's blog. Here you will find articles I've written about things I've made, which can be games, art or something else entirely.",
    author: "TechnicJelle",
    siteRootUrl: baseUrl,
    entries: blogPosts.reversed.map((f) => f.toAtomEntry(link: "$blogUrl/${f.path}")).toList(growable: false),
    entryIdPrefix: "urn:uuid:",
    //never change this:
    id: "urn:uuid:019dc1b3-1427-7fbf-b058-015b535012e1",
  );

  final futures = blogPosts.map((e) => e.writeHtml());
  await Future.wait(futures, eagerError: true);

  final List<Element> postCards = [];
  int currentYear = 0;
  for (final post in blogPosts.reversed) {
    if (currentYear != post.year) {
      currentYear = post.year;
      postCards.add(H2.text("$currentYear", autoLink: false));
    }
    postCards.add(post.generateCard());
  }

  return Body(
    header: generateHeader(filename: "Blog", showBlog: false),
    main: Main(
      children: [
        H1.text("Blog"),
        P.text(
          "This is my (TechnicJelle) blog! On this blog I write about things I make, which can be games, art or something else entirely",
        ),
        ...postCards,
      ],
    ),
    footer: generateFooter(),
  );
}

void generateBreadcrumbIndex({
  required String h1Text,
  required List<String> path,
  required List<Element> elements,
}) {
  String aggregate = "/${dirBlog.path}";
  final File breadCrumbIndex = File(p.joinAll([dirBuildBlog.path, ...path, "index.html"]));
  breadCrumbIndex.parent.createSync(recursive: true);
  breadCrumbIndex.writeAsStringSync(
    HTML(
      lang: "en",
      head: generateHead(title: "Blog ${path.join("/")}", extraStyles: ["blog-index"]),
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
            H1.text(h1Text),
            ...elements,
          ],
        ),
        footer: generateFooter(),
      ),
    ).build(),
  );
}

class BlogPost extends MdFile {
  int year;
  int month;
  int day;

  String get year4 => year.toStringDigits(4);

  String get month2 => month.toStringDigits();

  String get day2 => day.toStringDigits();

  BlogPost({
    required super.file,
    required this.year,
    required this.month,
    required this.day,
  });

  String get path => p.withoutExtension(p.relative(file.path, from: dirBlog.path));

  String get filename => p.basename(file.path);

  @override
  DateTime get publishedDate => DateTime.utc(year, month, day);

  Future<void> writeHtml() async {
    log.info("Writing blog post $path");
    final srcPostDir = Directory(p.dirname(file.path));
    final buildPostDir = Directory(p.join(dirBuildBlog.path, path))..createSync(recursive: true);
    final postHtml = File(p.join(buildPostDir.path, "index.html"));

    final String indexHTML = HTML(
      lang: "en",
      head: generateHead(title: title, extraStyles: ["blog-post"]),
      body: Body(
        header: generateHeader(
          breadcrumbs: [
            A.text("Blog", href: "/${dirBlog.path}"),
            A.text(year4, href: "/${dirBlog.path}/$year4"),
            A.text(month2, href: "/${dirBlog.path}/$year4/$month2"),
            A.text(day2, href: "/${dirBlog.path}/$year4/$month2/$day2"),
          ],
          filename: filename,
          showBlog: false,
        ),
        main: Main(
          children: elements,
        ),
        footer: generateFooter(),
      ),
    ).build();

    await postHtml.writeAsString(indexHTML);

    //Copy linked assets in the mdFile
    final List<Image> images = [];
    elements.collectOfType(into: images);
    for (final Image img in images) {
      final uri = Uri.parse(img.src);
      if (uri.scheme.isNotEmpty) continue;
      final imgFile = File(p.join(srcPostDir.path, img.src));
      if (!imgFile.existsSync()) {
        throw Exception("Blog post `$path` links to image `${imgFile.path}` but that file does not exist!");
      }
      final targetFile = File(p.join(buildPostDir.path, img.src));
      await imgFile.copy(targetFile.path);
    }

    //Copy linked videos in the mdFile
    final List<Video> videos = [];
    elements.collectOfType(into: videos);
    for (final Video vid in videos) {
      final uri = Uri.parse(vid.src);
      if (uri.scheme.isNotEmpty) continue;
      final vidFile = File(p.join(srcPostDir.path, vid.src));
      if (!vidFile.existsSync()) {
        throw Exception("Blog post `$path` links to video `${vidFile.path}` but that file does not exist!");
      }
      final targetFile = File(p.join(buildPostDir.path, vid.src));
      await vidFile.copy(targetFile.path);
    }
  }

  Element generateCard() {
    final String allText = Div(children: elements.where((e) => e is! Nav && e is! Hn)).innerText;
    final String teaser =
        "${allText.split(" ").getRange(0, 20).join(" ").replaceFirst(RegExp(r"[\s:,.]*$"), "")}...";
    final String monthName = monthNames[month - 1];
    return A(
      href: "/${dirBlog.path}/$path",
      classes: ["post"],
      children: [
        H3.text(title!, autoLink: false),
        P.text("Published on $day $monthName", classes: ["published"]),
        P.text(teaser, classes: ["teaser"]),
      ],
    );
  }
}
