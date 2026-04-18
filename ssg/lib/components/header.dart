import "package:path/path.dart" as p;
import "package:techs_html_bindings/elements.dart";

Header generateHeader({required String filename, List<A> breadcrumbs = const []}) {
  return Header(
    classes: ["mono-font"],
    children: [
      Nav(
        children: [
          A.text("TechnicJelle", href: "/"),
          Span.text("/", classes: ["small"]),
          for (final breadcrumb in breadcrumbs) ...[
            breadcrumb,
            Span.text("/", classes: ["small"]),
          ],
          Span.text(p.basenameWithoutExtension(filename)),
          Span.text(p.extension(filename), classes: ["small"]),
        ],
      ),
    ],
  );
}
