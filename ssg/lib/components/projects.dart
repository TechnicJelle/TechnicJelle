import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/tags.dart";
import "package:ssg/constants.dart";
import "package:ssg/log.dart";
import "package:ssg/projects_loading.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/utils.dart";

final Directory dirImages = Directory("build/images/project-visuals")..createSync(recursive: true);

Future<Section> generateProjectsSection(List<Project> projects) async {
  return Section(
    classes: ["two-col"],
    children: [
      for (final project in projects) await _generateProjectCard(project),
    ],
  );
}

Future<Element> _generateVisuals(Project project) async {
  final List<Element> visuals = [];
  for (final String visual in project.visuals) {
    visuals.add(await _generateVisual(project, visual));
  }
  return Div(
    classes: ["visuals"],
    children: visuals,
  );
}

Future<Element> _generateVisual(Project project, String link) async {
  final String ext = p.extension(link);
  if (ext.isEmpty) throw Exception("Extension could not be found in $link");
  switch (ext) {
    case ".png":
    case ".gif":
    case ".jpg":
    case ".jpeg":
    case ".webp":
    case ".svg":
    case ".pnj":
      return Image(
        src: await _downloadVisualIfNecessary(project, link),
        alt: "Screenshot of ${project.name}",
        loading: .lazy,
      );
    case ".mp4":
    case ".webm":
      return Video(
        src: await _downloadVisualIfNecessary(project, link),
        autoplay: true,
        muted: true,
        disablePictureInPicture: true,
        disableRemotePlayback: true,
        loop: true,
        playsInline: true,
        tabFocusable: false,
        loading: .lazy,
      );
    default:
      throw UnsupportedError('Unsupported Visual extension "$ext" in $link');
  }
}

///Download a local copy of the visual, instead of using the link from projects.yml
Future<String> _downloadVisualIfNecessary(Project project, String link) async {
  if (Platform.environment["ENABLE_VISUAL_DOWNLOADING"] != null) {
    final Uri uri = Uri.parse(link);

    final String filename = uri.getFileName();
    final dirVisuals = Directory(p.join(dirImages.path, project.category.clean(), project.name.clean()))
      ..createSync(recursive: true);
    final file = File(p.join(dirVisuals.path, filename));
    final String relativeUrl = "/${p.relative(file.path, from: dirBuild.path)}";

    log.info("Downloading visual $relativeUrl");

    final request = await http.getUrl(uri);
    final response = await request.close();

    //heehee
    if (response.statusCode / 100.0 >= 4.0) throw Exception("HTTP Error ${response.statusCode} at $link");

    await response.pipe(file.openWrite());

    return relativeUrl;
  }
  return link;
}

Future<Element> _generateProjectCard(Project project) async {
  final String projectID = project.name.clean();
  return Section(
    id: projectID,
    classes: ["card"],
    children: [
      if (project.visuals.isNotEmpty) await _generateVisuals(project),
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
              ),
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
