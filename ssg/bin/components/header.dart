import "package:path/path.dart" as p;
import "package:ssg/html.dart";

Header generateHeader({required String filename, List<A> breadcrumbs = const []}) {
  return Header(
    children: [
      Nav(
        classes: ["mono-font"],
        inlineStyles: ["display: flex", "align-items: baseline"],
        children: [
          A(href: "/", children: [T("TechnicJelle")]),
          Span(classes: ["small"], children: [T("/")]),
          for (final breadcrumb in breadcrumbs) ...[
            breadcrumb,
            Span(classes: ["small"], children: [T("/")]),
          ],
          Span(children: [T(p.basenameWithoutExtension(filename))]),
          Span(classes: ["small"], children: [T(p.extension(filename))]),
        ],
      ),
    ],
  );
}
