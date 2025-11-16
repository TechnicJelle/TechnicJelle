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
  final Table heroTable = md.whereType<Table>().first;
  md[md.indexOf(heroTable)] = generateHero(heroTable);
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

void replaceBadges(List<Element> md) {
  md.replace(
    test: (Element element) {
      if (element is Image) {
        final Uri src = Uri.parse(element.src);
        if (src.host == "img.shields.io" && src.pathSegments.first == "badge") {
          final String s = src.pathSegments.last;
          final int splitOnIndex = s.lastIndexOf("-");
          return generateBadge(
            label: s.substring(0, splitOnIndex).trim().replaceAll("--", "-"),
            labelColour: src.queryParameters["logoColor"]!,
            logo: src.queryParameters["logo"]!,
            backgroundColour: "#${s.substring(splitOnIndex + 1).trim()}",
          );
        }
      }
      return null;
    },
  );
}

List<Element> generateBadge({
  required String label,
  required String labelColour,
  required String logo,
  required String backgroundColour,
}) {
  if (logo == "openjdk") logo = "java";

  final File icon = File("images/icons/$logo.svg");
  return [
    Span(
      classes: ["badge"],
      inlineStyles: [
        "color: $labelColour",
        "background-color: $backgroundColour",
      ],
      children: [
        T(
          icon
              .readAsStringSync()
              .replaceAll(
                ' xmlns="http://www.w3.org/2000/svg">',
                ' xmlns="http://www.w3.org/2000/svg" width=24 height=24>',
              )
              .replaceAll('"/></svg>', '" fill="currentColor"/></svg>'),
        ),
        T(label),
      ],
    ),
    T(" "),
  ];
}

Body generateBody() {
  final List<Element> md = markdown(File("README.md").readAsStringSync());
  replaceHeroTable(md);
  replaceBadges(md);

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
