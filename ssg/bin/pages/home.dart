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
import "package:techs_html_bindings/utils.dart";

void createHomePage() {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(),
    body: generateBody(),
  ).build();
  File(p.join(dirBuild.path, "index.html")).writeAsStringSync(indexHTML);
}

void replaceHeroTable(List<Element> md) {
  final List<Table> tables = [];
  md.collectOfType(into: tables);

  final Table heroTable = tables.first;
  md.remove(heroTable);

  final List<H1> h1s = [];
  md.collectOfType(into: h1s);
  final int h1Index = md.indexOf(h1s.first);

  md.insert(h1Index + 1, generateHero(heroTable));
}

Section generateHero(Table table) {
  final List<TableHeader> ths = [];
  table.collectChildrenOfType(into: ths);
  final String img = ths.first.innerText.trim();
  final String haiku = ths.last.innerText.trim();
  return Section(
    classes: ["hero"],
    children: [
      T(img),
      P.text(haiku),
    ],
  );
}

Body generateBody() {
  final List<Element> md = markdown(File("README.md").readAsStringSync());
  replaceHeroTable(md);

  final List<Element> mainContent = [
    ...md,
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
