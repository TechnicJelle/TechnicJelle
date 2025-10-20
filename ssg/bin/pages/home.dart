import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/components/projects.dart";
import "package:ssg/components/table_of_contents.dart";
import "package:ssg/components/tags.dart";
import "package:ssg/components/webrings.dart";
import "package:ssg/constants.dart";
import "package:ssg/projects_loading.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";

void createHomePage() {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(),
    body: generateBody(),
  ).build();
  File(p.join(dirBuild.path, "index.html")).writeAsStringSync(indexHTML);
}

Body generateBody() {
  final List<Element> mainContent = [
    ...markdown(File("README.md")),
    ...generateProjects(),
    generateWebrings(),
  ];

  //generate ToC from the mainContent and insert it into the mainContent once it's done
  mainContent.insert(
    mainContent.indexOf(mainContent.firstWhere((element) => element.id == "projects")),
    generateToC(fromContent: mainContent),
  );

  return Body(
    header: generateHeader(filename: "README.md"),
    main: Main(children: mainContent),
    footer: generateFooter(),
  );
}

List<Element> generateProjects() {
  final List<Element> elements = [
    H2(children: [T("Projects")]),
    generateTagsList(withUsageAmount: true),
  ];
  categoriesProjectsMap.forEach((String category, List<Project> projects) {
    elements.addAll([
      H3(children: [T(category)]),
      generateProjectsSection(projects),
    ]);
  });
  return elements;
}
