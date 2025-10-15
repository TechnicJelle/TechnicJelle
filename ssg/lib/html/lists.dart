import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class ListItem extends Element {
  Iterable<Element> children;
  Iterable<String>? classes;

  ListItem({required this.children, this.classes});

  @override
  String build() {
    return "<li${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</li>";
  }
}

class UnorderedList extends Element {
  Iterable<ListItem> children;
  Iterable<String>? classes;

  UnorderedList({required this.children, this.classes});

  @override
  String build() {
    return "<ul${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</ul>";
  }
}

class OrderedList extends Element {
  Iterable<ListItem> children;
  Iterable<String>? classes;

  OrderedList({required this.children, this.classes});

  @override
  String build() {
    return "<ol${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</ol>";
  }
}
