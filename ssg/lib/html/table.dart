import "package:ssg/html/base.dart";

class Table extends Element {
  TableHead head;
  TableBody body;

  Table({
    required this.head,
    required this.body,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return "<table$modifiers>\n"
        "${head.build()}\n"
        "${body.build()}\n"
        "</table>";
  }
}

class TableHead extends Element {
  TableRowH row;

  TableHead({
    required this.row,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return "<thead$modifiers>\n"
        "${row.build()}\n"
        "</thead>";
  }
}

class TableRowH extends Element {
  Iterable<TableHeader> headers;

  TableRowH({
    required this.headers,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return "<tr$modifiers>\n"
        '${headers.map((el) => el.build()).join("\n")}\n'
        "</tr>";
  }
}

class TableHeader extends Element {
  TableHeader({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<th$modifiers>"
        "${children.map((el) => el.build()).join()}"
        "</th>";
  }
}

class TableBody extends Element {
  Iterable<TableRowB> rows;

  TableBody({
    required this.rows,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return "<tbody$modifiers>\n"
        '${rows.map((el) => el.build()).join("\n")}\n'
        "</tbody>";
  }
}

class TableRowB extends Element {
  Iterable<TableCell> cells;

  TableRowB({
    required this.cells,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return "<tr$modifiers>\n"
        '${cells.map((el) => el.build()).join("\n")}\n'
        "</tr>";
  }
}

class TableCell extends Element {
  TableCell({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<td$modifiers>"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</td>";
  }
}
