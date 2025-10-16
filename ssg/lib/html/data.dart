import "package:ssg/html.dart";

class Address extends Element {
  Address({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<address$modifiers>"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</address>";
  }
}

class Time extends Element {
  String datetime;

  Time({
    required this.datetime,
    required String visible,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: [T(visible)]);

  @override
  String build() {
    return '<time datetime="$datetime"$modifiers>'
        "${children.map((el) => el.build()).join()}"
        "</time>";
  }
}
