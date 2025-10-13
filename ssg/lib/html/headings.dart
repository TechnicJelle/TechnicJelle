import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Hn extends Element {
  int level;
  String? id;
  List<Element> children;
  List<String>? classes;

  Hn({required this.level, required this.children, this.classes, this.id});

  @override
  String build() {
    return "<h$level${id.id()}${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n\n")}'
        "</h$level>";
  }
}

class H1 extends Hn {
  H1({required super.children, super.classes, super.id}) : super(level: 1);
}

class H2 extends Hn {
  H2({required super.children, super.classes, super.id}) : super(level: 2);
}

class H3 extends Hn {
  H3({required super.children, super.classes, super.id}) : super(level: 3);
}

class H4 extends Hn {
  H4({required super.children, super.classes, super.id}) : super(level: 4);
}

class H5 extends Hn {
  H5({required super.children, super.classes, super.id}) : super(level: 5);
}

class H6 extends Hn {
  H6({required super.children, super.classes, super.id}) : super(level: 6);
}
