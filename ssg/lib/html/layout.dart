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
        '${children.map((el) => el.build()).join("\n")}\n'
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
        '${children.map((el) => el.build()).join("\n")}\n'
        "</section>";
  }
}

class Nav extends Element {
  Nav({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<nav$modifiers>\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</nav>";
  }
}

class Aside extends Element {
  Aside({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<aside$modifiers>\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</aside>";
  }
}
