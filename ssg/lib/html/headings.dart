import "package:ssg/html/base.dart";
import "package:ssg/html/text.dart";
import "package:ssg/utils.dart";

class Hn extends Element {
  ///Override this if you want the automatic links to have a different class.
  static String autoLinkClass = "link";

  ///Override this if you want to display something else than a 🔗 as the link.
  static Element autoLinkElement = T("🔗");

  int level;
  bool autoLink;

  Hn({
    required this.level,
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
    bool autoID = true,
    this.autoLink = true,
  }) {
    if (id == null && autoID) {
      id = innerText.clean();
    }
  }

  @override
  String build() {
    final Iterable<Element> thisChildren = [
      ...children,
      if (autoLink && id != null)
        A(
          classes: [autoLinkClass],
          href: "#${id!}",
          children: [autoLinkElement],
        ),
    ];
    return "<h$level$modifiers>"
        '${thisChildren.map((el) => el.build()).join("\n")}'
        "</h$level>";
  }
}

class H1 extends Hn {
  H1({required super.children, super.id, super.classes, super.inlineStyles, super.autoID, super.autoLink = false})
    : super(level: 1);
}

class H2 extends Hn {
  H2({required super.children, super.id, super.classes, super.inlineStyles, super.autoID, super.autoLink})
    : super(level: 2);
}

class H3 extends Hn {
  H3({required super.children, super.id, super.classes, super.inlineStyles, super.autoID, super.autoLink})
    : super(level: 3);
}

class H4 extends Hn {
  H4({required super.children, super.id, super.classes, super.inlineStyles, super.autoID, super.autoLink})
    : super(level: 4);
}

class H5 extends Hn {
  H5({required super.children, super.id, super.classes, super.inlineStyles, super.autoID, super.autoLink = false})
    : super(level: 5);
}

class H6 extends Hn {
  H6({required super.children, super.id, super.classes, super.inlineStyles, super.autoID, super.autoLink = false})
    : super(level: 6);
}
