import "dart:collection";
import "dart:io";

import "package:checked_yaml/checked_yaml.dart";
import "package:path/path.dart" as p;
import "package:ssg/atom/entry.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";
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

    final String content = Div(
      children: elements.where((element) => element != h1).toList(growable: false),
      args: {"xmlns": "http://www.w3.org/1999/xhtml"},
    ).build();

    final List<int> parts = p.split(sourcePath).map(int.tryParse).whereType<int>().toList(growable: false);
    if (parts.length != 3) throw Exception("Could not extract date from sourcePath!?");
    final publishedDate = DateTime(parts[0], parts[1], parts[2]).toUtc();

    return Entry(
      title: thisTitle,
      link: link,
      id: atomId,
      published: publishedDate.toIso8601String(),
      content: content,
      sourcePath: sourcePath,
    );
  }
}
