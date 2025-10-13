import "dart:io";

import "package:checked_yaml/checked_yaml.dart";
import "package:ssg/html.dart";
import "package:ssg/utils.dart";

class ProjectCategory {
  List<Project> projects;

  ProjectCategory({required this.projects});
}

class Project {
  String name;
  String url;
  List<String> tags;
  String? blog;

  Project({required this.name, required this.url, required this.tags, required this.blog});
}

Map<String, ProjectCategory> read(Map<dynamic, dynamic>? m) {
  if (m == null) throw Exception("Somehow, m was null!?");

  final Map<String, ProjectCategory> categories = {};
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

    categories[key] = ProjectCategory(projects: projects);
  });
  return categories;
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
  final List<Element> elements = [];
  checkedYamlDecode(
    File("projects.yml").readAsStringSync(),
    read,
  ).forEach((String key, ProjectCategory value) {
    elements.addAll([
      H2(children: [T(key)]),
      Div(
        classes: ["two-col"],
        children: [
          ...value.projects.map(generateProjectCard),
        ],
      ),
    ]);
  });
  return elements;
}
