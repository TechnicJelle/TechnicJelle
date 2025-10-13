import "dart:convert";

const HtmlEscape _htmlEscape = HtmlEscape();

extension HtmlEscaping on String {
  String escape() {
    return _htmlEscape.convert(this);
  }
}

extension Embedding1 on List<String>? {
  String classes() {
    final List<String>? classes = this;
    if (classes == null) return "";
    return ' class="${classes.join(" ")}"';
  }

  String styles() {
    final List<String>? styles = this;
    if (styles == null) return "";
    return ' style="${styles.join("; ")};"';
  }
}

extension Embedding2 on String? {
  String id() {
    final String? id = this;
    if (id == null) return "";
    return ' id="$id"';
  }
}

extension Embedding3 on String {
  String clean() {
    return replaceAll(r"\W+", " ").trim().replaceAll(" ", "-").toLowerCase();
  }
}
