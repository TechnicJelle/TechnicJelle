import "package:ssg/html/base.dart";

class ListItem extends Element {
  ListItem({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<li$modifiers>"
        '${children.map((el) => el.build()).join("\n")}'
        "</li>";
  }
}

class UnorderedList extends Element {
  UnorderedList({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<ul$modifiers>\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</ul>";
  }
}

class OrderedList extends Element {
  OrderedList({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<ol$modifiers>\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</ol>";
  }
}
