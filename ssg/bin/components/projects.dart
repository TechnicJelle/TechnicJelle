import "package:ssg/html.dart";

import "../projects_loading.dart";
import "tags.dart";

Section generateProjectsSection(List<Project> projects) {
  return Section(
    classes: ["two-col"],
    children: [
      for (final project in projects) _generateProjectCard(project),
    ],
  );
}

Element _generateProjectCard(Project project) {
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
      generateTagsList(tags: project.tags),
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
