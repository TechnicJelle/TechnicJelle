import "dart:io";

import "package:bindings_html/html.dart";

//TODO: Make not terrible

List<Element> markdown(File file) {
  final List<String> contents = file.readAsLinesSync();
  final List<Element> elements = [];
  for (int i = 0; i < contents.length; i++) {
    final String line = contents[i];

    const String h1 = "# ";
    const String h2 = "## ";
    const String h3 = "### ";
    const String h4 = "#### ";
    const String h5 = "##### ";
    const String h6 = "###### ";
    if (line.startsWith(h1)) {
      elements.add(H1(children: [T(line.replaceFirst(h1, ""))]));
    } else if (line.startsWith(h2)) {
      elements.add(H2(children: [T(line.replaceFirst(h2, ""))]));
    } else if (line.startsWith(h3)) {
      elements.add(H2(children: [T(line.replaceFirst(h3, ""))]));
    } else if (line.startsWith(h4)) {
      elements.add(H2(children: [T(line.replaceFirst(h4, ""))]));
    } else if (line.startsWith(h5)) {
      elements.add(H2(children: [T(line.replaceFirst(h5, ""))]));
    } else if (line.startsWith(h6)) {
      elements.add(H2(children: [T(line.replaceFirst(h6, ""))]));
    } else if (line.startsWith("<!---")) {
      //ignore
    } else {
      final RegExp image = RegExp(r"!\[(.*?)\]\((.*?)\)");
      final RegExp link = RegExp(r"\[(.*?)\]\((.*?)\)");
      final List<RegExpMatch> imageMatches = image.allMatches(line).toList();
      final List<RegExpMatch> linkMatches = link.allMatches(line).toList();
      if (imageMatches.isNotEmpty) {
        for (final Match match in imageMatches) {
          elements.add(Image(src: match.group(2)!, alt: match.group(1)!));
        }
      } else if (linkMatches.isNotEmpty) {
        for (final Match match in linkMatches) {
          elements.add(
            A(href: match.group(2)!, children: [T(match.group(1)!)]),
          );
        }
      } else {
        elements.add(P.text(line));
      }
    }
  }

  return elements;
}
