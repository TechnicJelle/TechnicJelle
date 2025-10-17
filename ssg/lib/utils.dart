import "dart:convert";

import "package:ssg/html/base.dart";

const HtmlEscape _htmlEscape = HtmlEscape();

extension HtmlEscaping on String {
  String escape() {
    return _htmlEscape.convert(this);
  }
}

extension Extension1 on Iterable<String>? {
  String classes() {
    final Iterable<String>? classes = this;
    if (classes == null) return "";
    return ' class="${classes.join(" ")}"';
  }

  String styles() {
    final Iterable<String>? styles = this;
    if (styles == null) return "";
    return ' style="${styles.join("; ")};"';
  }
}

extension Extension2 on String? {
  String id() {
    final String? id = this;
    if (id == null) return "";
    return ' id="$id"';
  }
}

extension Extension3 on String {
  String clean() {
    return toLowerCase().replaceAll(RegExp("[^a-z0-9 ]"), "").trim().replaceAll(" ", "-");
  }
}

extension Extension4 on Iterable<Element> {
  void collectOfType<E>({required List<E> into}) {
    for (final element in this) {
      if (element case final E e) {
        into.add(e);
      }
      element.children.collectOfType(into: into);
    }
  }
}
