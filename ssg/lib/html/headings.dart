import "package:ssg/html/base.dart";
import "package:ssg/html/text.dart";
import "package:ssg/utils.dart";

class Hn extends Element {
  int level;
  String? id;
  Iterable<Element> children;
  Iterable<String>? classes;
  bool autoID;
  bool autoLink;

  Hn({
    required this.level,
    required this.children,
    this.classes,
    this.id,
    this.autoID = true,
    this.autoLink = true,
  });

  @override
  String build() {
    if (autoID && id == null && children.length == 1) {
      final Element first = children.first;
      switch (first) {
        case T():
          id = first.text.clean();
        case A():
          if (first.children.length == 1) {
            if (first.children.first case final T first2) {
              id = first2.text.clean();
            }
          }
      }
    }
    final Iterable<Element> thisChildren = [
      ...children,
      if (autoLink && id != null)
        A(
          classes: ["link"],
          href: "#${id!}",
          children: [T(" 🔗")],
        ),
    ];
    return "<h$level${id.id()}${classes.classes()}>"
        '${thisChildren.map((el) => el.build()).join("\n\n")}'
        "</h$level>";
  }
}

class H1 extends Hn {
  H1({required super.children, super.classes, super.id, super.autoID, super.autoLink = false}) : super(level: 1);
}

class H2 extends Hn {
  H2({required super.children, super.classes, super.id, super.autoID, super.autoLink}) : super(level: 2);
}

class H3 extends Hn {
  H3({required super.children, super.classes, super.id, super.autoID, super.autoLink}) : super(level: 3);
}

class H4 extends Hn {
  H4({required super.children, super.classes, super.id, super.autoID, super.autoLink}) : super(level: 4);
}

class H5 extends Hn {
  H5({required super.children, super.classes, super.id, super.autoID, super.autoLink = false}) : super(level: 5);
}

class H6 extends Hn {
  H6({required super.children, super.classes, super.id, super.autoID, super.autoLink = false}) : super(level: 6);
}
