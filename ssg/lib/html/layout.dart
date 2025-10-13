import "package:ssg/html.dart";
import "package:ssg/utils.dart";

class Div extends Element {
  List<Element> children;
  List<String>? classes;

  Div({required this.children, this.classes});

  @override
  String build() {
    return "<div${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</div>";
  }
}

class Section extends Element {
  List<Element> children;
  List<String>? classes;

  Section({required this.children, this.classes});

  @override
  String build() {
    return "<section${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</section>";
  }
}
