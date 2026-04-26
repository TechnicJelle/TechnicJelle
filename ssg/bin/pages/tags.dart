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

final Directory dirTags = Directory(p.join(dirBuild.path, "tags"));

Future<void> createTagsPages() async {
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

  for (final MapEntry<String, List<Project>> entry in tagsAndTheirUsages.entries) {
    await _createTagPage(tag: entry.key, projects: entry.value);
  }
}

Future<void> _createTagPage({required String tag, required List<Project> projects}) async {
  final Directory tagDir = Directory(p.join(dirTags.path, cleanTag(tag)))..createSync();
  final String tagPage = HTML(
    lang: "en",
    head: generateHead(
      title: tag,
      extraLinks: [
        //TODO: Maybe a feed per project tag? But only show if you actually go to this tag page and search for linked feeds.
      ],
    ),
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
          await generateProjectsSection(projects),
        ],
      ),
      footer: generateFooter(),
    ),
  ).build();
  File(p.join(tagDir.path, "index.html")).writeAsStringSync(tagPage);
}
