import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Body extends Element {
  Header header;
  Main main;
  Footer footer;

  Body({required this.header, required this.main, required this.footer});

  @override
  String build() {
    return "<body>\n"
        "${header.build()}\n\n"
        "${main.build()}\n\n"
        "${footer.build()}\n"
        "</body>";
  }
}

class Header extends Element {
  Iterable<Element> children;
  Iterable<String>? classes;

  Header({required this.children, this.classes});

  @override
  String build() {
    return "<header${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</header>";
  }
}

class Main extends Element {
  Iterable<Element> children;
  Iterable<String>? classes;

  Main({required this.children, this.classes});

  @override
  String build() {
    return "<main${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</main>";
  }
}

class Footer extends Element {
  Iterable<Element> children;
  Iterable<String>? classes;

  Footer({required this.children, this.classes});

  @override
  String build() {
    return "<footer${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</footer>";
  }
}
