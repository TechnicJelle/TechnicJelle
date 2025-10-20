import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/html.dart";

import "../components/footer.dart";
import "../components/head.dart";
import "../components/header.dart";
import "../components/projects.dart";
import "../components/tags.dart";
import "../main.dart";
import "../projects_loading.dart";

final Directory dirTags = Directory(p.join(dirBuild.path, "tags"))..createSync();

void createTagsPages() {
  final String tagsPage = HTML(
    lang: "en",
    head: generateHead(title: "Tags"),
    body: Body(
      header: generateHeader(filename: "Tags"),
      main: Main(children: [
        H1(children: [T("All tags")]),
        generateTagsList(withUsageAmount: true),
      ]),
      footer: generateFooter(),
    ),
  ).build();
  File(p.join(dirTags.path, "index.html")).writeAsStringSync(tagsPage);

  tagsAndTheirUsages.forEach(_createTagPage);
}

void _createTagPage(String tag, List<Project> projects) {
  final Directory tagDir = Directory(p.join(dirTags.path, cleanTag(tag)))..createSync();
  final String tagPage = HTML(
    lang: "en",
    head: generateHead(title: tag),
    body: Body(
      header: generateHeader(
        breadcrumbs: [
          A(href: "/tags", children: [T("Tags")]),
        ],
        filename: tag,
      ),
      main: Main(
        children: [
          H1(
            children: [
              T("Projects with the tag"),
              Em(children: [T(tag)]),
            ],
          ),
          generateProjectsSection(projects),
        ],
      ),
      footer: generateFooter(),
    ),
  ).build();
  File(p.join(tagDir.path, "index.html")).writeAsStringSync(tagPage);
}
