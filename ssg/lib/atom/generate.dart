import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/atom/entry.dart";
import "package:ssg/constants.dart";
import "package:xml/xml.dart";

Future<void> generateAtomFeed({
  required Directory destinationPath,
  required String title,
  required String subtitle,
  required String author,
  required String siteRootUrl,
  required List<Entry> entries,
  required String id,
}) async {
  final File destinationFile = File(p.join(destinationPath.path, "feed.xml"));
  final builder = XmlBuilder()..declaration(encoding: "utf-8");
  builder.element(
    "feed",
    namespaces: {"http://www.w3.org/2005/Atom": ""},
    nest: () {
      builder
        ..element("title", nest: title)
        ..element("subtitle", nest: subtitle)
        ..element("link", attributes: {"href": "$siteRootUrl/${destinationFile.path}", "rel": "self"})
        ..element("link", attributes: {"href": siteRootUrl})
        ..element("updated", nest: DateTime.now().copyWith(microsecond: 0).toIso8601String())
        ..element("author", nest: () => builder.element("name", nest: author))
        ..element("id", nest: id);

      final Set<String> ids = {};
      for (final Entry entry in entries) {
        // Prevent duplicate IDs
        if (ids.contains(entry.id)) {
          throw Exception(
            "Post ${entry.sourcePath} does not have a unique atom-id `${entry.id}` in its frontmatter!",
          );
        }
        ids.add(entry.id);

        builder.element(
          "entry",
          nest: () {
            builder
              ..element("title", nest: entry.title)
              ..element("link", attributes: {"href": entry.link})
              ..element("id", nest: entry.id)
              ..element("published", nest: entry.published)
              ..element("content", attributes: {"type": "xhtml"}, nest: () => builder.xml(entry.content));
          },
        );
      }
    },
  );
  final XmlDocument document = builder.buildDocument();
  await File(p.join(dirBuild.path, destinationFile.path)).writeAsString(
    document.toXmlString(
      pretty: true,
      spaceBeforeSelfClose: (_) => true,
    ),
  );
}
