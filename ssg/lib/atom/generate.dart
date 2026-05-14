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
  String entryIdPrefix = "",
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
        ..element("link", attributes: {"href": "$siteRootUrl/${destinationPath.path}", "rel": "alternate"})
        ..element("link", attributes: {"href": siteRootUrl, "rel": "related"})
        ..element("updated", nest: DateTime.now().toAtomString())
        ..element("author", nest: () => builder.element("name", nest: author))
        ..element("id", nest: id);

      final Set<String> ids = {};
      for (final Entry entry in entries) {
        final String entryId = entryIdPrefix + entry.id;
        // Prevent duplicate IDs
        if (ids.contains(entryId)) {
          throw Exception(
            "Post ${entry.sourcePath} does not have a unique atom-id `$entryId` in its frontmatter!",
          );
        }
        ids.add(entryId);

        builder.element(
          "entry",
          nest: () {
            builder
              ..element("title", nest: entry.title)
              ..element("link", attributes: {"href": entry.link, "rel": "alternate"})
              ..element("id", nest: entryId)
              ..element("published", nest: entry.published)
              ..element("updated", nest: entry.updated);
            if (entry.summary != null) {
              builder.element("summary", nest: entry.summary);
            }
            builder.element(
              "content",
              attributes: {
                "type": "xhtml",
                if (entry.xmlLang != null) ...{"xml:lang": entry.xmlLang!},
                if (entry.xmlBase != null) ...{"xml:base": entry.xmlBase!},
              },
              nest: () => builder.xml(entry.content),
            );
          },
        );
      }
    },
  );
  final XmlDocument document = builder.buildDocument();
  await File(p.join(dirBuild.path, destinationFile.path)).writeAsString(
    document.toXmlString(
      pretty: true,
      indent: "\t",
      preserveWhitespace: (xmlNode) => xmlNode is XmlElement && ["pre", "p"].contains(xmlNode.localName),
      spaceBeforeSelfClose: (_) => true,
    ),
  );
}
