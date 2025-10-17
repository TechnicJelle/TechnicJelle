import "package:ssg/html/base.dart";

class Body extends Element {
  Header header;
  Main main;
  Footer footer;

  Body({
    required this.header,
    required this.main,
    required this.footer,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: [header, main, footer]);

  @override
  String build() {
    return "<body$modifiers>\n"
        "${header.build()}\n\n"
        "${main.build()}\n\n"
        "${footer.build()}\n"
        "</body>";
  }
}

class Header extends Element {
  Header({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<header$modifiers>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</header>";
  }
}

class Main extends Element {
  Main({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<main$modifiers>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</main>";
  }
}

class Footer extends Element {
  Footer({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<footer$modifiers>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</footer>";
  }
}
