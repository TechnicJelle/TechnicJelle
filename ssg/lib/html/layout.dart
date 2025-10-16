import "package:ssg/html.dart";

class Div extends Element {
  Div({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<div$modifiers>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</div>";
  }
}

class Section extends Element {
  Section({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<section$modifiers>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</section>";
  }
}
