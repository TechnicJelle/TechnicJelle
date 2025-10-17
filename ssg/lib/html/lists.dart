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
  Iterable<ListItem> items;

  UnorderedList({
    required this.items,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: items);

  @override
  String build() {
    return "<ul$modifiers>\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</ul>";
  }
}

class OrderedList extends Element {
  Iterable<ListItem> items;

  OrderedList({
    required this.items,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: items);

  @override
  String build() {
    return "<ol$modifiers>\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</ol>";
  }
}
