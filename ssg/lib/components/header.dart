import "package:path/path.dart" as p;
import "package:ssg/components/icons.dart";
import "package:techs_html_bindings/elements.dart";

Header generateHeader({
  required String filename,
  List<A> breadcrumbs = const [],
  bool showBlog = true,
  bool showBlogFeed = false,
}) {
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
      Nav(
        children: [
          if (showBlog) A.text("Blog", href: "/blog"),
          if (showBlogFeed)
            A(
              href: "/blog/feed.xml",
              target: .blank,
              classes: ["feed-with-icon"],
              children: [
                T("Feed"),
                getLogo("rss"),
              ],
            ),
        ],
      ),
    ],
  );
}
