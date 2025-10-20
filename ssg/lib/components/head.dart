import "package:techs_html_bindings/elements.dart";

Head generateHead({
  String? title,
  String description = "On this website you'll find info about me and my projects",
}) {
  String fullTitle = "TechnicJelle";
  if (title != null) {
    fullTitle = "$title | $fullTitle";
  }

  return Head(
    title: fullTitle,
    metas: [
      Meta.name(name: "viewport", content: "width=device-width, initial-scale=1"),
      Meta.name(name: "og:title", content: fullTitle),
      Meta.name(name: "description", content: description),
      Meta.name(name: "og:description", content: description),
      Meta.name(name: "theme-color", content: "#001FF1"),
      Meta.name(name: "og:image", content: "https://technicjelle.com/images/logo-128.gif"),
      Meta.httpEquiv(httpEquiv: "X-Clacks-Overhead", content: "GNU Terry Pratchett"),
    ],
    links: [
      Link.icon(
        type: "image/png",
        sizes: "32x32",
        href: "/favicon-32x32.png",
      ),
      Link.icon(
        type: "image/png",
        sizes: "16x16",
        href: "/favicon-16x16.png",
      ),
      ...Link.preloadedStylesheet(href: "/styles/main.css"),
    ],
    styles: [
      Style(css: "body { background: #151515; }"),
    ],
  );
}
