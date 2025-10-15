import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Table extends Element {
  TableHead head;
  TableBody body;

  Table({required this.head, required this.body});

  @override
  String build() {
    return "<table>\n"
        "${head.build()}\n"
        "${body.build()}\n"
        "</table>";
  }
}

class TableHead extends Element {
  TableRowH row;

  TableHead(this.row);

  @override
  String build() {
    return "<thead>\n"
        "${row.build()}\n"
        "</thead>";
  }
}

class TableRowH extends Element {
  Iterable<TableHeader> headers;

  TableRowH({required this.headers});

  @override
  String build() {
    return "<tr>\n"
        '${headers.map((el) => el.build()).join("\n")}\n'
        "</tr>";
  }
}

class TableHeader extends Element {
  Iterable<Element> children;
  Iterable<String>? styles;

  TableHeader({required this.children, this.styles});

  @override
  String build() {
    return "<th${styles.styles()}>"
        "${children.map((el) => el.build()).join()}"
        "</th>";
  }
}

class TableBody extends Element {
  Iterable<TableRowB> rows;

  TableBody(this.rows);

  @override
  String build() {
    return "<tbody>\n"
        '${rows.map((el) => el.build()).join("\n")}\n'
        "</tbody>";
  }
}

class TableRowB extends Element {
  Iterable<TableCell> cells;

  TableRowB(this.cells);

  @override
  String build() {
    return "<tr>\n"
        '${cells.map((el) => el.build()).join("\n")}\n'
        "</tr>";
  }
}

class TableCell extends Element {
  @override
  String build() {
    return "<td></td>";
  }
}
