import "dart:io";

import "package:checked_yaml/checked_yaml.dart";
import "package:github/github.dart";

import "log.dart";
import "main.dart";

class Project {
  String name;
  String url;
  List<String> tags;
  String? blog;
  String? descriptionOverride;

  Project({required this.name, required this.url, required this.tags, this.blog, this.descriptionOverride});

  static final Map<Project, Repository> _projectRepository = {};

  Repository? get _repository => _projectRepository[this];

  String? get description => descriptionOverride ?? _repository?.description;

  int get stars => _repository?.stargazersCount ?? 0;

  String? get starsUrl => _repository?.stargazersUrl;
}

final Map<String, List<Project>> categoriesProjectsMap = checkedYamlDecode(
  File("projects.yml").readAsStringSync(),
  _parse,
);

final Map<String, List<Project>> tagsAndTheirUsages = {};

Map<String, List<Project>> _parse(Map<dynamic, dynamic>? m) {
  if (m == null) throw Exception("Somehow, m was null!?");

  log.info("Parsing projects.yml...");

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

      final descriptionOverride = projectMap["description"];
      if (descriptionOverride is! String?) throw Exception("Unexpected element 5");

      final List<String> projectTags = [];
      for (final tag in tags) {
        if (tag is! String) throw Exception("Unexpected element 6");

        projectTags.add(tag);
      }
      projects.add(
        Project(
          name: key2,
          url: value2,
          tags: projectTags,
          blog: blog,
          descriptionOverride: descriptionOverride,
        ),
      );
    }

    categories[key] = projects;
  });
  log.info("Finished parsing projects.yml!");
  return categories;
}

Future<void> setupProjectRepository() async {
  // For recording the tag usages
  final List<Project> allProjectsList = [];
  final Set<String> allTagsSet = {};

  log.info("Retrieving project repository information...");

  for (final projects in categoriesProjectsMap.values) {
    allProjectsList.addAll(projects);

    for (final project in projects) {
      allTagsSet.addAll(project.tags);

      // If not authenticated, we won't make requests, to speed up the build process.
      if (github.auth.isAnonymous) continue;

      // If the link is not a github link, we can't retrieve information from it.
      if (!project.url.contains("github.com")) continue;

      final List<String> parts = project.url.split("/").where((element) => element.isNotEmpty).toList();
      final name = parts.removeLast();
      final owner = parts.removeLast();
      final repo = await github.repositories.getRepository(RepositorySlug(owner, name));
      Project._projectRepository[project] = repo;

      log.info("Retrieved information for ${repo.slug()}");
    }
  }

  log.info("Finished retrieving project repository information!");

  // Record tag usages
  for (final String tag in allTagsSet) {
    final List<Project> projects = [];
    for (final project in allProjectsList) {
      if (project.tags.contains(tag)) {
        projects.add(project);
      }
    }
    tagsAndTheirUsages[tag] = projects;
  }
}
