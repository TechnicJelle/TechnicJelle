import "dart:io";

import "package:checked_yaml/checked_yaml.dart";
import "package:ssg/html.dart";
import "package:ssg/utils.dart";

class Project {
  String name;
  String url;
  List<String> tags;
  String? blog;

  Project({required this.name, required this.url, required this.tags, required this.blog});
}

final Map<String, List<Project>> categoriesProjectsMap = checkedYamlDecode(
  File("projects.yml").readAsStringSync(),
  _parse,
);

Map<String, List<Project>> _parse(Map<dynamic, dynamic>? m) {
  if (m == null) throw Exception("Somehow, m was null!?");

  final Map<String, List<Project>> categories = {};
  m.forEach((key, value) {
    if (key is! String || value is! List) throw Exception("Unexpected element 1");

    final List<Project> projects = [];
    for (final projectMap in value) {
      if (projectMap is! Map) throw Exception("Unexpected element 2");

      final mapEntry = projectMap.entries.first;
      final key2 = mapEntry.key;
      final value2 = mapEntry.value;
      if (key2 is! String || value2 is! String) throw Exception("Unexpected element 3");

      final tags = projectMap["tags"];
      if (tags is! List) throw Exception("Unexpected element 4");

      final blog = projectMap["blog"];
      if (blog is! String?) throw Exception("Unexpected element 5");

      final List<String> projectTags = [];
      for (final tag in tags) {
        if (tag is! String) throw Exception("Unexpected element 6");

        projectTags.add(tag);
      }
      projects.add(Project(name: key2, url: value2, tags: projectTags, blog: blog));
    }

    categories[key] = projects;
  });
  return categories;
}

Section generateTags() {
  final Set<String> tagsSet = {};
  categoriesProjectsMap.forEach(
    (String category, List<Project> projects) {
      for (final project in projects) {
        tagsSet.addAll(project.tags);
      }
    },
  );

  final List<String> tagsList = tagsSet.toList()..sort();

  return Section(
    children: [
      P(
        classes: ["tags"],
        children: [
          T("Tags: "),
          ...tagsList.map((String tag) => Span(children: [T(tag)])),
        ],
      ),
    ],
  );
}

Element generateProjectCard(Project project) {
  return Section(
    classes: ["card"],
    children: [
      H4(
        id: project.name.clean(),
        children: [
          A(href: project.url, children: [T(project.name)]),
        ],
      ),
      P.text("Description goes here!"),
      if (project.blog != null) A(href: project.blog!, children: [T("Blog →")]),
      P(
        classes: ["tags"],
        children: [
          T("Tags: "),
          ...project.tags.map((String tag) => Span(children: [T(tag)])),
        ],
      ),
    ],
  );
}

List<Element> generateProjects() {
  final List<Element> elements = [
    H2(children: [T("Projects")]),
    generateTags(),
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
