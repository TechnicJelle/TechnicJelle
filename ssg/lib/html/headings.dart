import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class H1 extends Element {
  String? id;
  List<Element> children;
  List<String>? classes;

  H1({required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h1${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h1>";
  }
}

class H2 extends Element {
  String? id;
  List<Element> children;
  List<String>? classes;

  H2({required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h2${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h2>";
  }
}

class H3 extends Element {
  String? id;
  List<Element> children;
  List<String>? classes;

  H3({required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h3${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h3>";
  }
}

class H4 extends Element {
  String? id;
  List<Element> children;
  List<String>? classes;

  H4({required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h4${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h4>";
  }
}

class H5 extends Element {
  String? id;
  List<Element> children;
  List<String>? classes;

  H5({required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h5${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h5>";
  }
}

class H6 extends Element {
  String? id;
  List<Element> children;
  List<String>? classes;

  H6({required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h6${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h6>";
  }
}
