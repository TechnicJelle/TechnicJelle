import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/html.dart";
import "package:ssg/markdown.dart";

import "../components/footer.dart";
import "../components/head.dart";
import "../components/header.dart";
import "../components/projects.dart";
import "../components/table_of_contents.dart";
import "../components/tags.dart";
import "../components/webrings.dart";
import "../main.dart";
import "../projects_loading.dart";

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
