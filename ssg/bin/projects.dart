import "package:ssg/html.dart";

import "projects_loading.dart";

String tagToCSSClass(String tag) {
  return tag.replaceAll(" ", "-").replaceAll("#", "s").replaceAll("+", "p");
}

Element generateTagsList(Iterable<String> tags, {bool withUsageAmount = false}) {
  return UnorderedList(
    classes: ["tags"],
    items: tags.map(
      (String tag) => ListItem(
        classes: [tagToCSSClass(tag)],
        children: [
          A(
            href: "#",
            children: [
              T(tag),
              if (withUsageAmount) T("(${tagsAndTheirUsages[tag]})"),
            ],
          ),
        ],
      ),
    ),
  );
}

Element generateProjectCard(Project project) {
  return Section(
    classes: ["card"],
    children: [
      H4(
        children: [
          A(href: project.url, children: [T(project.name)]),
        ],
      ),
      P.text(project.description ?? "No description"),
      if (project.blog != null)
        A(
          href: project.blog!,
          classes: ["blog-link"],
          children: [T("Read about this project on my blog →")],
        ),
      generateTagsList(project.tags),
      if (project.stars > 0)
        P(
          classes: ["stars"],
          children: [
            A(
              classes: ["stealth-link"],
              href: project.starsUrl!,
              children: [T("⭐${project.stars}")],
            ),
          ],
        ),
    ],
  );
}

List<Element> generateProjects() {
  final List<String> allTagsList = tagsAndTheirUsages.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  final List<Element> elements = [
    H2(children: [T("Projects")]),
    generateTagsList(allTagsList, withUsageAmount: true),
  ];
  categoriesProjectsMap.forEach((String category, List<Project> projects) {
    elements.addAll([
      H3(children: [T(category)]),
      Div(
        classes: ["two-col"],
        children: [
          ...projects.map(generateProjectCard),
        ],
      ),
    ]);
  });
  return elements;
}
