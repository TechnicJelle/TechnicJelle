import "dart:collection";
import "dart:io";

import "package:checked_yaml/checked_yaml.dart";
import "package:path/path.dart" as p;
import "package:ssg/atom/entry.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";
import "package:techs_html_bindings/utils.dart";
import "package:uuid/uuid.dart";

class MdFile {
  final File file;
  final String content;
  final List<Element> _elements;
  Map<String, Object>? _frontmatter;

  UnmodifiableMapView<String, Object>? get frontmatter {
    final thisFrontmatter = _frontmatter;
    if (thisFrontmatter == null) return null;
    return UnmodifiableMapView(thisFrontmatter);
  }

  UnmodifiableListView<Element> get elements => UnmodifiableListView(_elements);

  H1? get h1 => elements.whereType<H1>().firstOrNull;

  String? get title => h1?.innerText;

  DateTime get publishedDate => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  MdFile({required this.file}) : content = file.readAsStringSync(), _elements = [] {
    if (content.contains("“") || content.contains("”")) {
      throw Exception("Post ${file.path} contains a stupid “quote”");
    } else if (content.contains("…")) {
      throw Exception("Post ${file.path} contains a stupid ellipsis…");
    } else if (content.contains("’")) {
      throw Exception("Post ${file.path} contains a stupid ‘RIGHT SINGLE QUOTATION MARK’");
    } else if (content.contains("‘")) {
      throw Exception("Post ${file.path} contains a stupid ‘LEFT SINGLE QUOTATION MARK’");
    }
    final RegExp checkFrontmatter = RegExp(r"^---$\n(.*?)\s*^---$\s*(.*)", dotAll: true, multiLine: true);
    final RegExpMatch? match = checkFrontmatter.firstMatch(content);
    if (match == null) {
      _elements.addAll(markdown(content));
    } else {
      final String? strFrontmatter = match.group(1);
      if (strFrontmatter == null) {
        throw Exception("Regex failure in frontmatter parsing of ${file.path}: missing group 1");
      }
      if (strFrontmatter.isEmpty) {
        _frontmatter = {};
      } else {
        _frontmatter = checkedYamlDecode(strFrontmatter, _parseFrontmatter);
      }

      final String? strRest = match.group(2);
      if (strRest == null) {
        throw Exception("Regex failure in frontmatter parsing of ${file.path}: missing group 2");
      }
      _elements.addAll(markdown(strRest));

      //TODO: Add verification that the pointed-to posts actually exist
      final String? prev = frontmatter?["prev"] as String?;
      final String? next = frontmatter?["next"] as String?;
      if (prev != null || next != null) {
        final nav = Nav(
          classes: ["center"],
          children: [
            P(
              children: [
                if (prev != null) A.text("← Previous Post", href: prev),
                if (prev != null && next != null) T(" | "),
                if (next != null) A.text("Next Post →", href: next),
              ],
            ),
          ],
        );
        _elements
          ..replace(test: (element) => element == h1 ? [element, nav] : null)
          ..add(nav);
      }
    }
  }

  Map<String, Object> _parseFrontmatter(Map<dynamic, dynamic>? m) {
    if (m == null) throw Exception("Somehow, m was null!?");

    final Map<String, Object> map = {};
    m.forEach((key, value) {
      if (key is! String) throw Exception("Unexpected key type");

      final Object? val = value;
      if (val == null) throw Exception("Value was null!?");
      map[key] = val;
    });

    return map;
  }

  Entry toAtomEntry({required String link}) {
    final String sourcePath = file.path;
    final thisFrontmatter = frontmatter;
    if (thisFrontmatter == null) throw Exception("Post $sourcePath does not have frontmatter!");
    final Object? atomId = thisFrontmatter["atom-id"];
    if (atomId == null) throw Exception("Post $sourcePath does not have an atom-id in its frontmatter!");
    if (atomId is! String) throw Exception("Post $sourcePath does not have a valid atom-id in its frontmatter!");
    if (atomId.isEmpty) throw Exception("Post $sourcePath has an empty atom-id in its frontmatter!");
    try {
      Uuid.parse(atomId);
    } on FormatException {
      throw Exception("Post $sourcePath atom-id `$atomId` is not a valid UUID!");
    }

    final String? thisTitle = title;
    if (thisTitle == null) throw Exception("Post $sourcePath does not have a title!");

    // TODO: Fix that this mutates the original elements list.
    //  It is not copied deeply enough.
    //  The children might be getting replaced by copies, but their parents are not getting replaced by copies,
    //  so the parents (which are shared between `elements` and `fixedElements` get their child replaced by a modified copy.
    //  But they're shared, so the replace affects both lists...

    //replace elements for use in an atom feed
    final List<Element> fixedElements = elements.where((element) => element != h1).toList()
      //make all media src's absolute URLs
      ..replace(
        test: (element) {
          final prefix = "$baseUrl/${p.join(p.dirname(sourcePath), p.basenameWithoutExtension(sourcePath))}/";
          return switch (element) {
            Image(:final src) => [element.copyWith(src: prefix + src)],
            Video(:final src) => [element.copyWith(src: prefix + src)],
            _ => null,
          };
        },
      )
      ..replace(
        test: (element) {
          if (element is! Pre) return null;
          final escapedChildren = element.children.toList()
            ..replace(test: (element) => element is T ? [T(element.text.escape())] : null);
          final Pre escapedPre = element.copyWith(children: escapedChildren);
          return [escapedPre];
        },
      )
      ..replace(
        test: (element) {
          if (element is! Hn) return null;
          return [element.copyWith(autoLink: false)];
        },
      )
      ..replace(
        test: (element) {
          if (element is! Nav) return null;
          final classes = element.classes;
          if (classes == null) return null;
          if (!classes.contains("center")) return null;

          final newClasses = classes.where((strClass) => strClass != "center");
          final newNav = element.copyWith(
            classes: newClasses.isEmpty ? null : newClasses,
            inlineStyles: ["text-align: center", ...?element.inlineStyles],
          );
          return [newNav];
        },
      )
      ..replace(
        test: (element) {
          if (element is! Span) return null;
          final classes = element.classes;
          if (classes == null) return null;
          if (!classes.contains("small")) return null;

          final newClasses = classes.where((strClass) => strClass != "small");
          final newSpan = element.copyWith(
            classes: newClasses.isEmpty ? null : newClasses,
            inlineStyles: ["font-size: 0.8em", ...?element.inlineStyles],
          );
          return [newSpan];
        },
      )
      ..replace(
        test: (element) {
          if (element is! Hn) return null;
          return [element.copyWith(autoLink: false)];
        },
      );

    final String content = Div(
      children: fixedElements,
      args: {"xmlns": "http://www.w3.org/1999/xhtml"},
    ).build();

    return Entry(
      title: thisTitle,
      link: link,
      id: atomId,
      published: publishedDate.toAtomString(),
      updated: publishedDate.toAtomString(),
      content: content,
      sourcePath: sourcePath,
      xmlLang: "en",
      xmlBase: link,
    );
  }
}
