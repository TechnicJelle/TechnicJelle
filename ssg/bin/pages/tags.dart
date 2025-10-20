import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/components/projects.dart";
import "package:ssg/components/tags.dart";
import "package:ssg/constants.dart";
import "package:ssg/projects_loading.dart";
import "package:techs_html_bindings/elements.dart";

final Directory dirTags = Directory(p.join(dirBuild.path, "tags"))..createSync();

void createTagsPages() {
  final String tagsPage = HTML(
    lang: "en",
    head: generateHead(title: "Tags"),
    body: Body(
      header: generateHeader(filename: "Tags"),
      main: Main(
        children: [
          H1(children: [T("All tags")]),
          generateTagsList(withUsageAmount: true),
        ],
      ),
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
