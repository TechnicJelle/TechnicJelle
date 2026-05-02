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

  MdFile({required this.file}) : content = file.readAsStringSync(), _elements = [] {
    if (content.contains("“") || content.contains("”")) {
      throw Exception("Post ${file.path} contains a stupid quote!");
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

  Entry toAtomEntry(String link) {
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
          if (element is! Code) return null;
          return element.children.toList()
            ..replace(test: (element) => element is T ? [T(element.text.escape())] : null);
        },
      );

    final String content = Div(
      children: fixedElements,
      args: {"xmlns": "http://www.w3.org/1999/xhtml"},
    ).build();

    final List<int> parts = p.split(sourcePath).map(int.tryParse).whereType<int>().toList(growable: false);
    if (parts.length != 3) throw Exception("Could not extract date from sourcePath!?");
    final publishedDate = DateTime.utc(parts[0], parts[1], parts[2]);

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
