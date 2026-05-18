import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/components/icons.dart";
import "package:ssg/components/projects.dart";
import "package:ssg/components/table_of_contents.dart";
import "package:ssg/components/webrings.dart";
import "package:ssg/constants.dart";
import "package:ssg/projects_loading.dart";
import "package:ssg/tag_store.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";
import "package:techs_html_bindings/utils.dart";

Future<void> createHomePage() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(
      extraStyles: ["home", "projects", "tags"],
    ),
    body: await generateBody(),
  ).build();
  File(p.join(dirBuild.path, "index.html")).writeAsStringSync(indexHTML);
}

void replaceHeroTable(List<Element> md) {
  final Table heroTable = md.whereType<Table>().first;
  md[md.indexOf(heroTable)] = generateHero(heroTable);
}

///Replaces the <Table> in the readme with a flexbox <Section>
Section generateHero(Table table) {
  final List<TableHeader> ths = [];
  table.collectChildrenOfType(into: ths);
  final Image img = ths.first.children.whereType<Image>().first;
  final Iterable<Element> haiku = ths.last.children;
  return Section(
    classes: ["hero"],
    children: [
      img,
      P(children: haiku),
    ],
  );
}

void replaceBadges(List<Element> md) {
  md.replace(
    test: (Element element) {
      if (element is A && element.children.firstOrNull is Image) {
        final Image image = element.children.first as Image;
        final replaced = replaceImageWithBadge(image);
        if (replaced == null) return null;
        final a = element.copyWith(target: .blank, children: [replaced]);
        return [a];
      } else if (element is Image) {
        final replaced = replaceImageWithBadge(element);
        if (replaced != null) return [replaced];
      }
      return null;
    },
  );
}

Element? replaceImageWithBadge(Image image) {
  final Uri src = Uri.parse(image.src);
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
  return null;
}

Element generateBadge({
  required String label,
  required String labelColour,
  required String logo,
  required String backgroundColour,
}) {
  // it's okay 🤫 don't worry about it
  // ignore: parameter_assignments
  if (logo == "openjdk") logo = "java";

  return Span(
    classes: ["badge"],
    inlineStyles: [
      "--label-colour: $labelColour",
      "--background-colour: $backgroundColour",
    ],
    children: [
      getLogo(logo),
      T(label),
    ],
  );
}

Future<Body> generateBody() async {
  final List<Element> md = markdown(File("README.md").readAsStringSync());
  replaceHeroTable(md);
  replaceBadges(md);

  final List<Element> mainContent = [
    ...md,
    ...await generateProjects(),
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
    footer: generateFooter(shouldDisplayLastUpdatedTime: true),
  );
}

Future<List<Element>> generateProjects() async {
  final List<Element> elements = [
    H2(children: [T("Projects")]),
    projectTagStore.generateTagsList(hrefPrefix: projectsHrefPrefix, withUsageAmount: true),
    generateTagCropper(),
  ];
  for (final MapEntry<String, List<Project>> entry in categoriesProjectsMap.entries) {
    final String category = entry.key;
    final List<Project> projects = entry.value;
    elements.addAll([
      H3(children: [T(category)]),
      await generateProjectsSection(projects),
    ]);
  }
  return elements;
}
