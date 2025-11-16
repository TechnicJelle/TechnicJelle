import "package:path/path.dart" as p;
import "package:ssg/components/tags.dart";
import "package:ssg/projects_loading.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/utils.dart";

Section generateProjectsSection(List<Project> projects) {
  return Section(
    classes: ["two-col"],
    children: [
      for (final project in projects) _generateProjectCard(project),
    ],
  );
}

Element _generateVisuals(Project project) {
  final List<Element> visuals = [];
  for (final String visual in project.visuals) {
    visuals.add(_generateVisual(visual));
  }
  return Div(
    classes: ["visuals"],
    children: visuals,
  );
}

Element _generateVisual(String link) {
  final String ext = p.extension(link);
  if (ext.isEmpty) throw Exception("Extension could not be found in $link");
  switch (ext) {
    case ".png":
    case ".gif":
    case ".jpg":
    case ".jpeg":
    case ".webp":
    case ".svg":
      return Image(src: link, alt: "");
    case ".mp4":
    case ".webm":
      return Video(
        src: link,
        autoplay: true,
        muted: true,
        disablePictureInPicture: true,
        disableRemotePlayback: true,
        loop: true,
        playsInline: true,
        tabFocusable: false,
      );
    default:
      throw UnsupportedError("Unsupported visual extension: $ext");
  }
}

Element _generateProjectCard(Project project) {
  final String projectID = project.name.clean();
  return Section(
    id: projectID,
    classes: ["card"],
    children: [
      if (project.visuals.isNotEmpty) _generateVisuals(project),
      Div(
        classes: ["card-title-bar"],
        children: [
          H4(
            autoID: false,
            children: [
              A(href: project.url, children: [T(project.name)]),
              A(
                classes: [Hn.autoLinkClass],
                href: "#$projectID",
                children: [Hn.autoLinkElement],
              )
            ],
          ),
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
      ),
      P.text(project.description ?? "No description"),
      if (project.blog != null)
        A(
          href: project.blog!,
          classes: ["blog-link"],
          children: [T("Read about this project on my blog →")],
        ),
      generateTagsList(tags: project.tags),
    ],
  );
}
